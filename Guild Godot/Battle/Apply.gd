extends LOADER

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
	43:"ACCURACY_DOWN", 44:"AGILITY_UP", 45:"AGILITY_DOWN", 46:"LUCK_UP", 47:"LUCK_DOWN"}

# Attack type
enum {PHYSIC, MAGIC}
var dtype = {PHYSIC:"físico", MAGIC:"mágico"}
var dlanes = {0:"do fundo", 1:"do meio", 2:"da frente"}

func apply_effect(who, effect, target, t_id, logs):
	var stat = effect[0]
	var value = effect[1]
	var type = effect[2]
	var times = effect[3]
	var TargetStat = target.get_stats(stat)
	var finalval = TargetStat + value
	var valmax = 9999
	for i in range(times):
		if stat == HP and value < 0:
			var dmg = target.take_damage(type, abs(value))
			if target.classe == "boss" and who.classe != "boss":
				who.update_hate(dmg, t_id)
		elif stat == HP:
			valmax = target.get_stats(HP_MAX)
		elif stat == MP:
			valmax = target.get_stats(MP_MAX)
		if TargetStat + value > valmax:
			finalval = valmax
		target.set_stats(stat, finalval)
		if target.get_health() > 0.2*target.get_max_health():
			target.remove_status("HP_CRITICAL")
	logs.display_text(target.get_name()+" agora tem "+str(target.get_stats(stat))+" de "+dstats[stat])

func apply_status(status, target, attacker, logs):
	var type = sstats[status[1]]
	var value = status[0]
	var atkm = attacker.get_atkm()
	if value:
		logs.display_text(target.get_name()+" agora está sob o efeito de "+type)
		target.add_status(type, atkm, 3)
		if type == "ATTACK_UP":
			var atk = target.get_atk()
			target.set_stats(ATK, 6*atk/5)
			logs.display_text(target.get_name()+" aumentou seu ataque fisico")
		elif type == "ATTACK_DOWN":
			var atk = target.get_atk()
			target.set_stats(ATK, 5*atk/6)
			logs.display_text(target.get_name()+" teve seu ataque fisico diminuido")
		elif type == "MAGIC_ATTACK_UP":
			#var atkm = target.get_atkm()
			target.set_stats(ATKM, 6*atkm/5)
			logs.display_text(target.get_name()+" aumentou seu ataque magico")
		elif type == "MAGIC_ATTACK_DOWN":
			#var atkm = target.get_atkm()
			target.set_stats(ATKM, 5*atkm/6)
			logs.display_text(target.get_name()+" teve seu ataque magico diminuida")
		elif type == "DEFENSE_UP":
			var def = target.get_def()
			target.set_stats(DEF, 6*def/5)
			logs.display_text(target.get_name()+" aumentou sua defesa fisica")
		elif type == "DEFENSE_DOWN":
			var def = target.get_def()
			target.set_stats(DEF, 5*def/6)
			logs.display_text(target.get_name()+" teve sua defesa fisica diminuida")
		elif type == "MAGIC_DEFENSE_UP":
			var defm = target.get_def()
			target.set_stats(DEFM, 6*defm/5)
			logs.display_text(target.get_name()+" aumentou sua defesa magica")
		elif type == "MAGIC_DEFENSE_DOWN":
			var defm = target.get_def()
			target.set_stats(DEFM, 5*defm/6)
			logs.display_text(target.get_name()+" teve sua defesa magica diminuida")
		elif type == "ACCURACY_UP":
			var acc = target.get_acc()
			target.set_stats(ACC, 6*acc/5)
			logs.display_text(target.get_name()+" aumentou sua acurácia")
		elif type == "ACCURACY_DOWN":
			var acc = target.get_acc()
			target.set_stats(ACC, 5*acc/6)
			logs.display_text(target.get_name()+" teve sua acurácia diminuida")
		elif type == "AGILITY_UP":
			var agi = target.get_agi()
			target.set_stats(AGI, 6*agi/5)
			logs.display_text(target.get_name()+" aumentou sua agilidade")
		elif type == "AGILITY_DOWN":
			var agi = target.get_agi()
			target.set_stats(AGI, 5*agi/6)
			logs.display_text(target.get_name()+" teve sua agilidade diminuida")
		elif type == "LUCK_UP":
			var luck = target.get_lck()
			target.set_stats(LCK, 6*luck/5)
			logs.display_text(target.get_name()+" aumentou sua sorte fisica")
		elif type == "LUCK_DOWN":
			var luck = target.get_lck()
			target.set_stats(LCK, 5*luck/6)
			logs.display_text(target.get_name()+" teve sua sorte diminuida")
		elif type == "MAX_HP_UP":
			var hp_max = target.get_max_health()
			var hp = target.get_health()
			var diferenca = hp_max
			target.set_stats(HP_MAX, 3*hp_max/2)
			var increase = target.get_max_health()
			target.set_stats(HP, hp + (increase - diferenca))
			logs.display_text(target.get_name()+" ganhou vida maxima excedente")
		elif type == "MAX_MP_UP":
			var mp_max = target.get_max_mp()
			var mp = target.get_health()
			var diferenca = mp_max
			target.set_stats(MP_MAX, 3*mp_max/2)
			var increase = target.get_max_mp()
			target.set_stats(MP, mp + (increase - diferenca))
			logs.display_text(target.get_name()+" ganhou mp maximo excedente")
		elif type == "MAX_HP_DOWN":
			var hp_max = target.get_max_health()
			var hp = target.get_health()
			target.set_stats(HP_MAX, 2*hp_max/3)
			if hp > hp_max:
				target.set_stats(HP, HP_MAX)
			logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
		elif type == "MAX_MP_DOWN":
			var mp_max = target.get_max_mp()
			var mp = target.get_mp()
			target.set_stats(MP_MAX, 2*mp_max/3)
			if mp > mp_max:
				target.set_stats(MP, MP_MAX)
			logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
		elif type == "BLIND":
			var acc = target.get_acc()
			target.set_stats(ACC, acc/10)
			logs.display_text(target.get_name()+" teve a visão comprometida, não consegue acertar seus alvos")
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
			logs.display_text(target.get_name()+" foi amaldiçoado. todos seus status foram reduzidos pela metade")
		elif type == "HASTE":
			var agi = target.get_agi()
			target.set_stats(AGI, agi*2)
			logs.display_text(target.get_name()+" ganhou o dobro de agilidade")
		elif type == "SLOW":
			var agi = target.get_agi()
			target.set_stats(AGI, agi/2)
			logs.display_text(target.get_name()+" perdeu metade de sua agilidade")

	else:
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
		logs.display_text(target.get_name()+" não está mais sob o efeito de "+sstats[type])
		target.remove_status(sstats[type])

func result_status(status, values, target, logs):
	if status == "POISON":
		var hp = target.get_health()
		var dmg = values[1] - target.get_defm()
		target.set_stats(HP, hp-dmg)
		logs.display_text(target.get_name()+" levou "+str(dmg)+" de dano de Poison")
	elif status == "REGEN":
		var hp = target.get_health()
		var max_hp = target.get_max_health()
		target.set_stats(HP, hp+(max_hp)*0.05)
		logs.display_text(target.get_name()+" recuperou "+str(0.05*max_hp)+" de HP")
	elif status == "BURN":
		var hp = target.get_health()
		target.set_stats(HP, hp-10)
		logs.display_text(target.get_name()+" levou 10 de dano de Burn")
	elif status == "PARALYSIS":
		randomize()
		var chance = rand_range(0, 99)
		if chance < 50:
			#target.execute_action("Pass", 0)
			logs.display_text(target.get_name()+" esta paralisado, não consegue atacar")
			return -1
	elif status == "FREEZE":
		#target.execute_action("Pass", 0)
		logs.display_text(target.get_name()+" esta congelado, não consegue atacar")
		return -1
	elif status == "BERSERK":
		#var atk = target.get_atk()
		#randomize()
		#var rand = rand_range(-LOADER.List.size(), 0)
		#target.execute_action("Attack", rand)
		logs.display_text(target.get_name()+" esta fora de controle, atacará qualquer um em sua frente")
		return -2
	elif status == "UNDEAD":
		#randomize()
		#var rand = rand_range(-LOADER.List.size(), 3)
		#target.execute_action("Attack", rand)
		logs.display_text(target.get_name()+" atacará qualquer alvo")
		return -2
	elif status == "PETRIFY":
		#target.execute_action("Pass", 0)
		logs.display_text(target.get_name()+" esta petrificado, não consegue atacar")
		return -1
	elif status == "KO":
		return -1
		#target.execute_action("Pass", 0)
	elif status == "SLEEP":
		var hp = target.get_health()
		target.set_stats(HP, hp + hp*0.05)
		var mp = target.get_mp()
		target.set_stats(MP, mp + mp*0.05)
		#target.execute_action("Pass", 0)
		logs.display_text(target.get_name()+" esta dormindo, não consegue atacar")	
		return -1
	return 0