extends Node

var dstats = {HP:"HP", HP_MAX:"HP máximo",MP:"MP", MP_MAX:"MP máximo", ATK:"ATK", ATKM:"ATKM", DEF:"DEF", DEFM:"DEFM", AGI:"AGI", ACC:"ACC", LCK:"LCK"}
# Stats
enum {HP, HP_MAX, MP, MP_MAX, ATK, ATKM, DEF, DEFM, AGI, ACC, LCK}

var sstats = {0:"CONFUSION", 1:"POISON", 2:"BURN", 3:"SLOW", 
	4:"HASTE", 5:"BERSERK", 6:"REGEN", 7:"UNDEAD", 8:"PETRIFY", 9:"SILENCE", 
	10:"BLIND", 11:"DOOM", 12:"PARALYSIS", 13:"MAX_HP_DOWN", 14:"MAX_MP_DOWN", 
	15:"SLEEP", 16:"FLOAT", 17:"UNKILLABLE", 18:"VISIBILITY", 19:"REFLECT", 
	20:"CONTROL", 21:"CHARM", 22:"HP_CRITICAL", 23:"CURSE", 24:"STOP", 
	25:"HIDDEN", 26:"FREEZE", 27:"IMMOBILIZE", 28:"KO", 29:"VEIL", 30:"TRAPPED", 31:"ATTACK_UP",
	32:"ATTACK_DOWN", 33:"DEFENSE_UP", 34:"DEFENSE_DOWN", 35:"MAGIC_DEFENSE_UP", 37:"MAGIC_DEFENSE_DOWN",
	38:"MAGIC_ATTACK_UP", 39:"MAGIC_ATTACK_DOWN", 40:"MAX_HP_UP", 41:"MAX_MP_UP", 42:"ACCURACY_UP",
	43:"ACCURACY_DOWN", 44:"AGILITY_UP", 45:"AGILITY_DOWN", 46:"LUCK_UP", 47:"LUCK_DOWN", 48:"FEAR"}

# Attack type
enum {PHYSIC, MAGIC}

const MAX_VALUE = 9999

func apply_effect(who: Entity, effect: StatEffect, target: Entity):
	var ret = -1 # Stat difference for displaying numbers
	var tipo = -1 # 0 for HP, 1 for MP
	
	var stat = effect.get_id()
	var base_value = effect.get_value()
	var type = effect.get_type()
	
	# Should be HP or MP
	var affected_stat = target.get_stats(stat)
	var lv = who.get_level()
	var target_lv = who.get_level()

#	Previous calculation: commented in case we want to reuse it
#		var basedamage = atk + ((atk*lv/32)*(atk*lv/32))
#		var maxdamage = ((value*(512-def)*basedamage)/(33*512))
#		var truedamage
#		truedamage = ceil(maxdamage)
#		truedamage = truedamage*rand_range(89, 100)/100
#		print("[APPLY] dano base: -" ,ceil(basedamage))
#		print("[APPLY] dano maximo: " , ceil(maxdamage))
#		print("[APPLY] resultado: " , ceil(truedamage))
	
	var final_value = 0
	var max_value = 9999
	var value = 0
	var atk_scalar = 1.0
	var def_scalar = 1.0
	
	print("[APPLY EFFECT] "+effect.format())
	
	# Offensive case: Damages HP
	if stat == HP and base_value < 0:
		print("[APPLY EFFECT] Offensive")
		tipo = 0
		
		# TODO: Make skill type consistent
		if (typeof(type) == TYPE_STRING and type == "PHYSIC" or typeof(type) == TYPE_INT and type == PHYSIC):
			print("[APPLY EFFECT] Physical attack")
			atk_scalar = target.get_stats(ATK)
			def_scalar = target.get_stats(DEF)
		else:
			print("[APPLY EFFECT] Magic attack")
			atk_scalar = target.get_stats(ATKM)
			def_scalar = target.get_stats(DEFM)
			
		var ceil_value = ceil(base_value*(atk_scalar/150.0 + 1.0) + (def_scalar * target_lv / 2.0))
		value = floor(ceil_value*rand_range(89, 100)/100)
		value = min(0, value)
		final_value = affected_stat + value
		ret = abs(value)
		if LOCAL.IN_BATTLE and target.classe == "boss" and who.classe != "boss":
			who.update_hate(value, target.index)
	# Support case: Heals HP
	elif stat == HP:
		print("[APPLY EFFECT] Recovery")
		# Cannot heal above MAX HP
		atk_scalar = target.get_stats(ATKM)
		var ceil_value = base_value*(atk_scalar/200.0 + 1.0)
		value = floor(ceil_value*rand_range(89, 100)/100)
		value = min(MAX_VALUE, value)
		max_value = target.get_stats(HP_MAX)
		final_value = affected_stat + value
		tipo = 0
		ret = -ceil(value)
		if final_value > max_value:
			final_value = max_value
			ret = -ceil(max_value - target.get_health())
	elif stat == MP:
		print("[APPLY EFFECT] MP")
		# Cannot heal above MAX MP
		max_value = target.get_stats(MP_MAX)
		tipo = 1
		final_value = affected_stat + base_value
		if final_value > max_value:
			final_value = max_value
			ret = abs(max_value - target.get_mp())
		if final_value < 0:
			final_value = 0
	print("[APPLY EFFECT] Final value: "+str(final_value))
	target.set_stats(stat, final_value)

	if target.get_health() > 0.2*target.get_max_health():
		target.remove_status("HP_CRITICAL")
	
	return [ret, tipo]

func apply_status(status, target, attacker):
	var type = sstats[status[1]]
	var value = status[0]
	var atkm = attacker.get_atkm()
	print("[APPLY] APPLYING STATUS "+type+str(value))
	if value > 0:
		randomize()
		var chance = rand_range(0, 99)
		if chance <= value*100:
			value = 1
		else:
			value = 0
	if value == 1:
		#logs.display_text(target.get_name()+" agora está sob o efeito de "+type)
		target.add_status(type, atkm, 3)
		if type == "ATTACK_UP":
			var atk = target.get_atk()
			target.set_stats(ATK, 6*atk/5)
			#logs.display_text(target.get_name()+" aumentou seu ataque fisico")
		elif type == "ATTACK_DOWN":
			var atk = target.get_atk()
			target.set_stats(ATK, 5*atk/6)
			#logs.display_text(target.get_name()+" teve seu ataque fisico diminuido")
		elif type == "MAGIC_ATTACK_UP":
			#var atkm = target.get_atkm()
			target.set_stats(ATKM, 6*atkm/5)
			#logs.display_text(target.get_name()+" aumentou seu ataque magico")
		elif type == "MAGIC_ATTACK_DOWN":
			#var atkm = target.get_atkm()
			target.set_stats(ATKM, 5*atkm/6)
			#logs.display_text(target.get_name()+" teve seu ataque magico diminuida")
		elif type == "DEFENSE_UP":
			var def = target.get_def()
			target.set_stats(DEF, 6*def/5)
			#logs.display_text(target.get_name()+" aumentou sua defesa fisica")
		elif type == "DEFENSE_DOWN":
			var def = target.get_def()
			target.set_stats(DEF, 5*def/6)
			#logs.display_text(target.get_name()+" teve sua defesa fisica diminuida")
		elif type == "MAGIC_DEFENSE_UP":
			var defm = target.get_def()
			target.set_stats(DEFM, 6*defm/5)
			#logs.display_text(target.get_name()+" aumentou sua defesa magica")
		elif type == "MAGIC_DEFENSE_DOWN":
			var defm = target.get_def()
			target.set_stats(DEFM, 5*defm/6)
			#logs.display_text(target.get_name()+" teve sua defesa magica diminuida")
		elif type == "ACCURACY_UP":
			var acc = target.get_acc()
			target.set_stats(ACC, 6*acc/5)
			#logs.display_text(target.get_name()+" aumentou sua acurácia")
		elif type == "ACCURACY_DOWN":
			var acc = target.get_acc()
			target.set_stats(ACC, 5*acc/6)
			#logs.display_text(target.get_name()+" teve sua acurácia diminuida")
		elif type == "AGILITY_UP":
			var agi = target.get_agi()
			target.set_stats(AGI, 6*agi/5)
			#logs.display_text(target.get_name()+" aumentou sua agilidade")
		elif type == "AGILITY_DOWN":
			var agi = target.get_agi()
			target.set_stats(AGI, 5*agi/6)
			#logs.display_text(target.get_name()+" teve sua agilidade diminuida")
		elif type == "LUCK_UP":
			var luck = target.get_lck()
			target.set_stats(LCK, 6*luck/5)
			#logs.display_text(target.get_name()+" aumentou sua sorte fisica")
		elif type == "LUCK_DOWN":
			var luck = target.get_lck()
			target.set_stats(LCK, 5*luck/6)
			#logs.display_text(target.get_name()+" teve sua sorte diminuida")
		elif type == "MAX_HP_UP":
			var hp_max = target.get_max_health()
			var hp = target.get_health()
			var diferenca = hp_max
			target.set_stats(HP_MAX, 3*hp_max/2)
			var increase = target.get_max_health()
			target.set_stats(HP, hp + (increase - diferenca))
			#logs.display_text(target.get_name()+" ganhou vida maxima excedente")
		elif type == "MAX_MP_UP":
			var mp_max = target.get_max_mp()
			var mp = target.get_health()
			var diferenca = mp_max
			target.set_stats(MP_MAX, 3*mp_max/2)
			var increase = target.get_max_mp()
			target.set_stats(MP, mp + (increase - diferenca))
			#logs.display_text(target.get_name()+" ganhou mp maximo excedente")
		elif type == "MAX_HP_DOWN":
			var hp_max = target.get_max_health()
			var hp = target.get_health()
			target.set_stats(HP_MAX, 2*hp_max/3)
			if hp > hp_max:
				target.set_stats(HP, HP_MAX)
			#logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
		elif type == "MAX_MP_DOWN":
			var mp_max = target.get_max_mp()
			var mp = target.get_mp()
			target.set_stats(MP_MAX, 2*mp_max/3)
			if mp > mp_max:
				target.set_stats(MP, MP_MAX)
			#logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
		elif type == "BLIND":
			var acc = target.get_acc()
			target.set_stats(ACC, acc/10)
			#logs.display_text(target.get_name()+" teve a visão comprometida, não consegue acertar seus alvos")
		elif type == "BERSERK":
			var atk = target.get_atk()
			target.set_stats(ATK, atk + 40)
		elif type == "CURSE":
			var hp = target.get_health()
			var agi = target.get_agi()
			var atk = target.get_atk()
			#var atkm = target.get_atkm()
			var def = target.get_def()
			var defm = target.get_defm()
			var acc = target.get_acc()
			target.set_stats(HP, hp/2)
			target.set_stats(AGI, agi/2)
			target.set_stats(ATK, atk/2)
			target.set_stats(ATKM, atkm/2)
			target.set_stats(DEF, def/2)
			target.set_stats(DEFM, defm/2)
			target.set_stats(ACC, acc/2)
			#logs.display_text(target.get_name()+" foi amaldiçoado. todos seus status foram reduzidos pela metade")
		elif type == "HASTE":
			var agi = target.get_agi()
			target.set_stats(AGI, agi*2)
			#logs.display_text(target.get_name()+" ganhou o dobro de agilidade")
		elif type == "SLOW":
			var agi = target.get_agi()
			target.set_stats(AGI, agi/2)
			#logs.display_text(target.get_name()+" perdeu metade de sua agilidade")
		elif type == "FEAR":
			var agi = target.get_agi()
			var atk = target.get_atk()
			target.set_stats(AGI, 3*agi/4)
			target.set_stats(ATK, 3*atk/4)
			#logs.display_text(target.get_name()+" esta amedrontado. perdeu agilidade e ataque")

	elif value == -1:
		print("WILL REMOVE STATUS "+str(type))
		target.remove_status(type)
		if type == "ATTACK_UP":
			var atk = target.get_atk()
			target.set_stats(ATK, 5*atk/6)
		elif type == "ATTACK_DOWN":
			var atk = target.get_atk()
			target.set_stats(ATK, 6*atk/5)
		elif type == "MAGIC_ATTACK_UP":
			#var atkm = target.get_atkm()
			target.set_stats(ATKM, 5*atkm/6)
		elif type == "MAGIC_ATTACK_DOWN":
			#var atkm = target.get_atkm()
			target.set_stats(ATKM, 6*atkm/5)
		elif type == "DEFENSE_UP":
			var def = target.get_def()
			target.set_stats(DEF, 5*def/6)
		elif type == "DEFENSE_DOWN":
			var def = target.get_def()
			target.set_stats(DEF, 6*def/5)
		elif type == "MAGIC_DEFENSE_UP":
			var defm = target.get_def()
			target.set_stats(DEFM, 5*defm/6)
		elif type == "MAGIC_DEFENSE_DOWN":
			var defm = target.get_def()
			target.set_stats(DEFM, 6*defm/5)
		elif type == "ACCURACY_UP":
			var acc = target.get_acc()
			target.set_stats(ACC, 5*acc/6)
		elif type == "ACCURACY_DOWN":
			var acc = target.get_acc()
			target.set_stats(ACC, 6*acc/5)
		elif type == "AGILITY_UP":
			var agi = target.get_agi()
			target.set_stats(AGI, 5*agi/6)
		elif type == "AGILITY_DOWN":
			var agi = target.get_agi()
			target.set_stats(AGI, 6*agi/5)
		elif type == "LUCK_UP":
			var luck = target.get_lck()
			target.set_stats(LCK, 5*luck/6)
		elif type == "LUCK_DOWN":
			var luck = target.get_lck()
			target.set_stats(LCK, 6*luck/5)
		elif type == "MAX_HP_UP":
			var hp_max = target.get_max_health()
			var hp = target.get_health()
			target.set_stats(HP_MAX, 2*hp_max/3)
			if hp > hp_max:
				target.set_stats(HP, HP_MAX)
		elif type == "MAX_MP_UP":
			var mp_max = target.get_max_mp()
			var mp = target.get_health()
			target.set_stats(MP_MAX, 2*mp_max/3)
			if mp > mp_max:
				target.set_stats(MP, MP_MAX)
		elif type == "MAX_HP_DOWN":
			var hp_max = target.get_max_health()
			var hp = target.get_health()
			target.set_stats(HP_MAX, 3*hp_max/2)
		elif type == "MAX_MP_DOWN":
			var mp_max = target.get_max_mp()
			var mp = target.get_mp()
			target.set_stats(MP_MAX, 3*mp_max/2)
		elif type == "BLIND":
			var acc = target.get_acc()
			target.set_stats(ACC, acc*10)
		elif type == "BERSERK":
			var atk = target.get_atk()
			target.set_stats(ATK, atk - 40)
		elif type == "CURSE":
			var hp = target.get_health()
			var agi = target.get_agi()
			var atk = target.get_atk()
			#var atkm = target.get_atkm()
			var def = target.get_def()
			var defm = target.get_defm()
			var acc = target.get_acc()
			target.set_stats(HP, hp*2)
			target.set_stats(AGI, agi*2)
			target.set_stats(ATK, atk*2)
			target.set_stats(ATKM, atkm*2)
			target.set_stats(DEF, def*2)
			target.set_stats(DEFM, defm*2)
			target.set_stats(ACC, acc*2)
		elif type == "HASTE":
			var agi = target.get_agi()
			target.set_stats(AGI, agi/2)
		elif type == "SLOW":
			var agi = target.get_agi()
			target.set_stats(AGI, agi*2)
		elif type == "FEAR":
			var agi = target.get_agi()
			var atk = target.get_atk()
			target.set_stats(AGI, 4*agi/3)
			target.set_stats(ATK, 4*atk/3)
		elif type == "KO":
			target.remove_all_status()
		#logs.display_text(target.get_name()+" não está mais sob o efeito de "+type)

func result_status(status, values, target, logs):
	var can_move = 0
	var result = -1
	if status == "POISON":
		var hp = target.get_health()
		var dmg = values[1] - target.get_defm()
		target.set_stats(HP, hp-dmg)
		result = dmg
		#logs.display_text(target.get_name()+" levou "+str(dmg)+" de dano de Poison")
	elif status == "REGEN":
		var hp = target.get_health()
		var max_hp = target.get_max_health()
		result = target.set_stats(HP, hp+floor(max_hp*0.05))
		#logs.display_text(target.get_name()+" recuperou "+str(-result)+" de HP")
	elif status == "BURN":
		var hp = target.get_health()
		target.set_stats(HP, hp-10)
		result = 10
		#logs.display_text(target.get_name()+" levou 10 de dano de Burn")
	elif status == "PARALYSIS":
		randomize()
		var chance = rand_range(0, 99)
		if chance < 50:
			#target.execute_action("Pass", 0)
			#logs.display_text(target.get_name()+" esta paralisado, não consegue atacar")
			can_move = -1
	elif status == "FEAR":
		randomize()
		var chance = rand_range(0, 99)
		if chance < 26:
			#target.execute_action("Pass", 0)
			#logs.display_text(target.get_name()+" esta apavorado, não consegue atacar")
			can_move = -1
	elif status == "FREEZE":
		#target.execute_action("Pass", 0)
		#logs.display_text(target.get_name()+" esta congelado, não consegue atacar")
		can_move =  -1
	elif status == "BERSERK":
		#var atk = target.get_atk()
		#randomize()
		#var rand = rand_range(-LOADER.List.size(), 0)
		#target.execute_action("Attack", rand)
		#logs.display_text(target.get_name()+" esta fora de controle, atacará qualquer um em sua frente")
		can_move =  -2
	elif status == "UNDEAD":
		#randomize()
		#var rand = rand_range(-LOADER.List.size(), 3)
		#target.execute_action("Attack", rand)
		#logs.display_text(target.get_name()+" atacará qualquer alvo")
		can_move = -2
	elif status == "PETRIFY":
		#target.execute_action("Pass", 0)
		#logs.display_text(target.get_name()+" esta petrificado, não consegue atacar")
		can_move = -1
	elif status == "KO":
		can_move = -1
		#target.execute_action("Pass", 0)
	elif status == "SLEEP":
		var hp = target.get_health()
		target.set_stats(HP, hp + floor(hp*0.05))
		result = floor(hp*0.05)
		#target.execute_action("Pass", 0)
		#logs.display_text(target.get_name()+" esta dormindo, não consegue atacar")	
		can_move = -1
	return [can_move, result]
