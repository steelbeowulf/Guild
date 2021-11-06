class_name Apply

# Stats
enum { HP, HP_MAX, MP, MP_MAX, ATK, ATKM, DEF, DEFM, AGI, ACC, LCK }

# Attack type
enum { PHYSIC, MAGIC }

const DSTATS = {
	HP: "HP",
	HP_MAX: "HP máximo",
	MP: "MP",
	MP_MAX: "MP máximo",
	ATK: "ATK",
	ATKM: "ATKM",
	DEF: "DEF",
	DEFM: "DEFM",
	AGI: "AGI",
	ACC: "ACC",
	LCK: "LCK"
}

const SSTATS = {
	0: "CONFUSION",
	1: "POISON",
	2: "BURN",
	3: "SLOW",
	4: "HASTE",
	5: "BERSERK",
	6: "REGEN",
	7: "UNDEAD",
	8: "PETRIFY",
	9: "SILENCE",
	10: "BLIND",
	11: "DOOM",
	12: "PARALYSIS",
	13: "MAX_HP_DOWN",
	14: "MAX_MP_DOWN",
	15: "SLEEP",
	16: "FLOAT",
	17: "UNKILLABLE",
	18: "VISIBILITY",
	19: "REFLECT",
	20: "CONTROL",
	21: "CHARM",
	22: "HP_is_criticalICAL",
	23: "CURSE",
	24: "STOP",
	25: "HIDDEN",
	26: "FREEZE",
	27: "IMMOBILIZE",
	28: "KO",
	29: "VEIL",
	30: "TRAPPED",
	31: "ATTACK_UP",
	32: "ATTACK_DOWN",
	33: "DEFENSE_UP",
	34: "DEFENSE_DOWN",
	35: "MAGIC_DEFENSE_UP",
	37: "MAGIC_DEFENSE_DOWN",
	38: "MAGIC_ATTACK_UP",
	39: "MAGIC_ATTACK_DOWN",
	40: "MAX_HP_UP",
	41: "MAX_MP_UP",
	42: "ACCURACY_UP",
	43: "ACCURACY_DOWN",
	44: "AGILITY_UP",
	45: "AGILITY_DOWN",
	46: "LUCK_UP",
	47: "LUCK_DOWN",
	48: "FEAR"
}

const MAX_VALUE = 9999


func apply_effect(
	who: Entity,
	effect: StatEffect,
	target: Entity,
	action_type: String,
	is_hit: bool,
	is_critical: bool
):
	var ret = 0  # Stat difference for displaying numbers
	var type = -1  # 0 for HP, 1 for MP

	var stat = effect.get_id()
	var base_value = effect.get_value()
	var type = effect.get_type()

	# Should be HP or MP
	var affected_stat = target.get_stats(stat)
	var lv = who.get_level()
	var target_lv = target.get_level()
	#var user_luck = who.get_stat("LCK")
	#var target_luck = target.get_stat("LCK")

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

	print("[APPLY EFFECT] " + action_type + effect.format())
	if is_hit:
		# Offensive case: Damages HP
		if stat == HP and base_value < 0:
			print("[APPLY EFFECT] Offensive")
			type = 0

			# TODO: Make skill type consistent
			if (
				typeof(type) == TYPE_STRING and type == "PHYSIC"
				or typeof(type) == TYPE_INT and type == PHYSIC
			):
				print("[APPLY EFFECT] Physical attack")
				atk_scalar = target.get_stats(ATK)
				def_scalar = target.get_stats(DEF)
			else:
				print("[APPLY EFFECT] Magic attack")
				atk_scalar = target.get_stats(ATKM)
				def_scalar = target.get_stats(DEFM)

			var ceil_value = ceil(
				base_value * (atk_scalar / 150.0 + 1.0) + (def_scalar * target_lv / 2.0)
			)
			value = floor(ceil_value * rand_range(89, 100) / 100)
			value = min(0, value)
			final_value = affected_stat + value
			ret = abs(value)
			if LOCAL.in_battle and target.type == "Enemy" and who.type != "Enemy":
				who.update_hate(value, target.index)
		# Support case: Heals HP
		elif stat == HP:
			print("[APPLY EFFECT] Recovery")
			# Cannot heal above MAX HP
			atk_scalar = target.get_stats(ATKM)
			var ceil_value = base_value * (atk_scalar / 200.0 + 1.0)
			value = floor(ceil_value * rand_range(89, 100) / 100)
			value = min(MAX_VALUE, value)
			max_value = target.get_stats(HP_MAX)
			final_value = affected_stat + value
			type = 0
			ret = -ceil(value)
			if final_value > max_value:
				final_value = max_value
				ret = -ceil(max_value - target.get_stat("HP"))
		elif stat == MP:
			print("[APPLY EFFECT] MP")
			# Cannot heal above MAX MP
			max_value = target.get_stats(MP_MAX)
			type = 1
			final_value = affected_stat + base_value
			if final_value > max_value:
				final_value = max_value
				ret = abs(max_value - target.get_stat("MP"))
			if final_value < 0:
				final_value = 0

		#Fix this later with the correct is_criticalical is_hit cap
		#var is_critical_chance = min(100, floor((user_luck + lv - target_lv)/3.53))
		#if(floor(rand_range(0,100.99)) <= is_critical_chance):
		#	final_value = final_value * 2
		#is_criticalical is_hit flag needed

		print("[APPLY EFFECT] Final value: " + str(final_value))
		target.set_stat(stat, final_value)

		if target.get_stat("HP") > 0.2 * target.get_stat("HP_MAX"):
			target.remove_status("HP_CRITICAL")
	if is_critical:
		ret = ret * 2
	return [ret, type]


# TODO: Status class
# TODO: Add back log functionality
func apply_status(status_type: Array, target: Entity, attacker: Entity):
	var type = SSTATS[status_type[1]]
	var value = status_type[0]
	var atkm = attacker.get_stat("ATKM")
	print("[APPLY] Applying status_type ", type, " ", str(value), " on ", target.get_name())
	if value > 0:
		randomize()
		var chance = rand_range(0, 99)
		if chance <= value * 100:
			value = 1
		else:
			value = 0
	if value == 1:
		#logs.display_text(target.get_name()+" agora está sob o efeito de "+type)
		target.add_status(type, atkm, 3)
		if type == "ATTACK_UP":
			var atk = target.get_stat("ATK")
			target.set_stat(ATK, 6 * atk / 5)
			#logs.display_text(target.get_name()+" aumentou seu ataque fisico")
		elif type == "ATTACK_DOWN":
			var atk = target.get_stat("ATK")
			target.set_stat(ATK, 5 * atk / 6)
			#logs.display_text(target.get_name()+" teve seu ataque fisico diminuido")
		elif type == "MAGIC_ATTACK_UP":
			#var atkm = target.get_stat("ATKM")
			target.set_stat(ATKM, 6 * atkm / 5)
			#logs.display_text(target.get_name()+" aumentou seu ataque magico")
		elif type == "MAGIC_ATTACK_DOWN":
			#var atkm = target.get_stat("ATKM")
			target.set_stat(ATKM, 5 * atkm / 6)
			#logs.display_text(target.get_name()+" teve seu ataque magico diminuida")
		elif type == "DEFENSE_UP":
			var def = target.get_stat("DEF")
			target.set_stat(DEF, 6 * def / 5)
			#logs.display_text(target.get_name()+" aumentou sua defesa fisica")
		elif type == "DEFENSE_DOWN":
			var def = target.get_stat("DEF")
			target.set_stat(DEF, 5 * def / 6)
			#logs.display_text(target.get_name()+" teve sua defesa fisica diminuida")
		elif type == "MAGIC_DEFENSE_UP":
			var defm = target.get_stat("DEF")
			target.set_stat(DEFM, 6 * defm / 5)
			#logs.display_text(target.get_name()+" aumentou sua defesa magica")
		elif type == "MAGIC_DEFENSE_DOWN":
			var defm = target.get_stat("DEF")
			target.set_stat(DEFM, 5 * defm / 6)
			#logs.display_text(target.get_name()+" teve sua defesa magica diminuida")
		elif type == "ACCURACY_UP":
			var acc = target.get_stat("ACC")
			target.set_stat(ACC, 6 * acc / 5)
			#logs.display_text(target.get_name()+" aumentou sua acurácia")
		elif type == "ACCURACY_DOWN":
			var acc = target.get_stat("ACC")
			target.set_stat(ACC, 5 * acc / 6)
			#logs.display_text(target.get_name()+" teve sua acurácia diminuida")
		elif type == "AGILITY_UP":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, 6 * agi / 5)
			#logs.display_text(target.get_name()+" aumentou sua agilidade")
		elif type == "AGILITY_DOWN":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, 5 * agi / 6)
			#logs.display_text(target.get_name()+" teve sua agilidade diminuida")
		elif type == "LUCK_UP":
			var luck = target.get_stat("LCK")
			target.set_stat(LCK, 6 * luck / 5)
			#logs.display_text(target.get_name()+" aumentou sua sorte fisica")
		elif type == "LUCK_DOWN":
			var luck = target.get_stat("LCK")
			target.set_stat(LCK, 5 * luck / 6)
			#logs.display_text(target.get_name()+" teve sua sorte diminuida")
		elif type == "MAX_HP_UP":
			var hp_max = target.get_stat("HP_MAX")
			var hp = target.get_stat("HP")
			var diferenca = hp_max
			target.set_stat(HP_MAX, 3 * hp_max / 2)
			var increase = target.get_stat("HP_MAX")
			target.set_stat(HP, hp + (increase - diferenca))
			#logs.display_text(target.get_name()+" ganhou vida maxima excedente")
		elif type == "MAX_MP_UP":
			var mp_max = target.get_stat("MP_MAX")
			var mp = target.get_stat("HP")
			var diferenca = mp_max
			target.set_stat(MP_MAX, 3 * mp_max / 2)
			var increase = target.get_stat("MP_MAX")
			target.set_stat(MP, mp + (increase - diferenca))
			#logs.display_text(target.get_name()+" ganhou mp maximo excedente")
		elif type == "MAX_HP_DOWN":
			var hp_max = target.get_stat("HP_MAX")
			var hp = target.get_stat("HP")
			target.set_stat(HP_MAX, 2 * hp_max / 3)
			if hp > hp_max:
				target.set_stat(HP, HP_MAX)
			#logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
		elif type == "MAX_MP_DOWN":
			var mp_max = target.get_stat("MP_MAX")
			var mp = target.get_stat("MP")
			target.set_stat(MP_MAX, 2 * mp_max / 3)
			if mp > mp_max:
				target.set_stat(MP, MP_MAX)
			#logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
		elif type == "BLIND":
			var acc = target.get_stat("ACC")
			target.set_stat(ACC, acc / 10)
			#logs.display_text(target.get_name()+" teve a visão comprometida")
		elif type == "BERSERK":
			var atk = target.get_stat("ATK")
			target.set_stat(ATK, atk + 40)
		elif type == "CURSE":
			var hp = target.get_stat("HP")
			var agi = target.get_stat("AGI")
			var atk = target.get_stat("ATK")
			#var atkm = target.get_stat("ATKM")
			var def = target.get_stat("DEF")
			var defm = target.get_stat("DEFM")
			var acc = target.get_stat("ACC")
			target.set_stat(HP, hp / 2)
			target.set_stat(AGI, agi / 2)
			target.set_stat(ATK, atk / 2)
			target.set_stat(ATKM, atkm / 2)
			target.set_stat(DEF, def / 2)
			target.set_stat(DEFM, defm / 2)
			target.set_stat(ACC, acc / 2)
			#logs.display_text(target.get_name()+" foi amaldiçoado")
		elif type == "HASTE":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, agi * 2)
			#logs.display_text(target.get_name()+" ganhou o dobro de agilidade")
		elif type == "SLOW":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, agi / 2)
			#logs.display_text(target.get_name()+" perdeu metade de sua agilidade")
		elif type == "FEAR":
			var agi = target.get_stat("AGI")
			var atk = target.get_stat("ATK")
			target.set_stat(AGI, 3 * agi / 4)
			target.set_stat(ATK, 3 * atk / 4)
			#logs.display_text(target.get_name()+" esta amedrontado. perdeu agilidade e ataque")

	elif value == -1:
		print("[APPLY] Will remove status_type " + str(type))
		target.remove_status(type)
		if type == "ATTACK_UP":
			var atk = target.get_stat("ATK")
			target.set_stat(ATK, 5 * atk / 6)
		elif type == "ATTACK_DOWN":
			var atk = target.get_stat("ATK")
			target.set_stat(ATK, 6 * atk / 5)
		elif type == "MAGIC_ATTACK_UP":
			#var atkm = target.get_stat("ATKM")
			target.set_stat(ATKM, 5 * atkm / 6)
		elif type == "MAGIC_ATTACK_DOWN":
			#var atkm = target.get_stat("ATKM")
			target.set_stat(ATKM, 6 * atkm / 5)
		elif type == "DEFENSE_UP":
			var def = target.get_stat("DEF")
			target.set_stat(DEF, 5 * def / 6)
		elif type == "DEFENSE_DOWN":
			var def = target.get_stat("DEF")
			target.set_stat(DEF, 6 * def / 5)
		elif type == "MAGIC_DEFENSE_UP":
			var defm = target.get_stat("DEF")
			target.set_stat(DEFM, 5 * defm / 6)
		elif type == "MAGIC_DEFENSE_DOWN":
			var defm = target.get_stat("DEF")
			target.set_stat(DEFM, 6 * defm / 5)
		elif type == "ACCURACY_UP":
			var acc = target.get_stat("ACC")
			target.set_stat(ACC, 5 * acc / 6)
		elif type == "ACCURACY_DOWN":
			var acc = target.get_stat("ACC")
			target.set_stat(ACC, 6 * acc / 5)
		elif type == "AGILITY_UP":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, 5 * agi / 6)
		elif type == "AGILITY_DOWN":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, 6 * agi / 5)
		elif type == "LUCK_UP":
			var luck = target.get_stat("LCK")
			target.set_stat(LCK, 5 * luck / 6)
		elif type == "LUCK_DOWN":
			var luck = target.get_stat("LCK")
			target.set_stat(LCK, 6 * luck / 5)
		elif type == "MAX_HP_UP":
			var hp_max = target.get_stat("HP_MAX")
			var hp = target.get_stat("HP")
			target.set_stat(HP_MAX, 2 * hp_max / 3)
			if hp > hp_max:
				target.set_stat(HP, HP_MAX)
		elif type == "MAX_MP_UP":
			var mp_max = target.get_stat("MP_MAX")
			var mp = target.get_stat("HP")
			target.set_stat(MP_MAX, 2 * mp_max / 3)
			if mp > mp_max:
				target.set_stat(MP, MP_MAX)
		elif type == "MAX_HP_DOWN":
			var hp_max = target.get_stat("HP_MAX")
			var hp = target.get_stat("HP")
			target.set_stat(HP_MAX, 3 * hp_max / 2)
		elif type == "MAX_MP_DOWN":
			var mp_max = target.get_stat("MP_MAX")
			var mp = target.get_stat("MP")
			target.set_stat(MP_MAX, 3 * mp_max / 2)
		elif type == "BLIND":
			var acc = target.get_stat("ACC")
			target.set_stat(ACC, acc * 10)
		elif type == "BERSERK":
			var atk = target.get_stat("ATK")
			target.set_stat(ATK, atk - 40)
		elif type == "CURSE":
			var hp = target.get_stat("HP")
			var agi = target.get_stat("AGI")
			var atk = target.get_stat("ATK")
			#var atkm = target.get_stat("ATKM")
			var def = target.get_stat("DEF")
			var defm = target.get_stat("DEFM")
			var acc = target.get_stat("ACC")
			target.set_stat(HP, hp * 2)
			target.set_stat(AGI, agi * 2)
			target.set_stat(ATK, atk * 2)
			target.set_stat(ATKM, atkm * 2)
			target.set_stat(DEF, def * 2)
			target.set_stat(DEFM, defm * 2)
			target.set_stat(ACC, acc * 2)
		elif type == "HASTE":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, agi / 2)
		elif type == "SLOW":
			var agi = target.get_stat("AGI")
			target.set_stat(AGI, agi * 2)
		elif type == "FEAR":
			var agi = target.get_stat("AGI")
			var atk = target.get_stat("ATK")
			target.set_stat(AGI, 4 * agi / 3)
			target.set_stat(ATK, 4 * atk / 3)
		elif type == "KO":
			target.remove_all_status()
		#logs.display_text(target.get_name()+" não está mais sob o efeito de "+type)


# TODO: Status class
# TODO: Add back log functionality
func result_status(status_type: String, values: Array, target: Entity, _logs: Node):
	var can_move = 0
	var result = -1
	if status_type == "POISON":
		var hp = target.get_stat("HP")
		var dmg = values[1] - target.get_stat("DEFM")
		target.set_stat(HP, hp - dmg)
		result = dmg
		#logs.display_text(target.get_name()+" levou "+str(dmg)+" de dano de Poison")
	elif status_type == "REGEN":
		var hp = target.get_stat("HP")
		var max_hp = target.get_stat("HP_MAX")
		result = target.set_stat(HP, hp + floor(max_hp * 0.05))
		#logs.display_text(target.get_name()+" recuperou "+str(-result)+" de HP")
	elif status_type == "BURN":
		var hp = target.get_stat("HP")
		target.set_stat(HP, hp - 10)
		result = 10
		#logs.display_text(target.get_name()+" levou 10 de dano de Burn")
	elif status_type == "PARALYSIS":
		randomize()
		var chance = rand_range(0, 99)
		if chance < 50:
			#target.execute_action("Pass", 0)
			#logs.display_text(target.get_name()+" esta paralisado, não consegue atacar")
			can_move = -1
	elif status_type == "FEAR":
		randomize()
		var chance = rand_range(0, 99)
		if chance < 26:
			#target.execute_action("Pass", 0)
			#logs.display_text(target.get_name()+" esta apavorado, não consegue atacar")
			can_move = -1
	elif status_type == "FREEZE":
		#target.execute_action("Pass", 0)
		#logs.display_text(target.get_name()+" esta congelado, não consegue atacar")
		can_move = -1
	elif status_type == "BERSERK":
		#var atk = target.get_stat("ATK")
		#randomize()
		#var rand = rand_range(-LOADER.List.size(), 0)
		#target.execute_action("Attack", rand)
		#logs.display_text(target.get_name()+" esta fora de controle, atacará qualquer um em sua frente")
		can_move = -2
	elif status_type == "UNDEAD":
		#randomize()
		#var rand = rand_range(-LOADER.List.size(), 3)
		#target.execute_action("Attack", rand)
		#logs.display_text(target.get_name()+" atacará qualquer alvo")
		can_move = -2
	elif status_type == "PETRIFY":
		#target.execute_action("Pass", 0)
		#logs.display_text(target.get_name()+" esta petrificado, não consegue atacar")
		can_move = -1
	elif status_type == "KO":
		can_move = -1
		#target.execute_action("Pass", 0)
	elif status_type == "SLEEP":
		var hp = target.get_stat("HP")
		target.set_stat(HP, hp + floor(hp * 0.05))
		result = floor(hp * 0.05)
		#target.execute_action("Pass", 0)
		#logs.display_text(target.get_name()+" esta dormindo, não consegue atacar")
		can_move = -1
	return [can_move, result]
