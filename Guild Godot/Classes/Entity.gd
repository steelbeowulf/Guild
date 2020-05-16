extends "Stats.gd"

var id
var index
var level
var xp
var sprite
var animations
var nome
var stats
var buffs
var alive
var health
var position
var classe
var skills
var graphics
var status = {}
var dead = false
var resist = {}
var tipo
var info
	#fire, water, ligthting, ice, earth, wind, holy, darkness]
var elem = {0:"PHYSIC", 1:"MAGIC", 2:"FIRE", 3:"WATER", 4:"ELECTRIC", 5:"ICE", 6:"EARTH", 7:"WIND", 8:"HOLY", 9:"DARKNESS"}

enum {PHYSIC, MAGIC, FIRE, WATER, ELECTRIC, ICE, EARTH, WIND, HOLY, DARKNESS}
enum {HP, HP_MAX, MP, MP_MAX, ATK, ATKM, DEF, DEFM, AGI, ACC, EVA, LCK}

func die():
	self.set_stats(HP, 0)
	add_status("KO", 999, 999)

func get_status():
	return status

func remove_all_status():
	status = {}

func remove_status(effect):
	if effect == "SLOW":
		var agi = self.get_agi()
		self.set_stats(AGI, agi*2)
		#logs.display_text(self.get_name()+" recuperou agilidade")
	elif effect == "HASTE":
		var agi = self.get_agi()
		self.set_stats(AGI, agi/2)
		#logs.display_text(target.get_name()+" ganhou o dobro de agilidade")
	elif effect == "MAX_HP_DOWN":
		var hp_max = self.get_max_health()
		var hp = self.get_health()
		self.set_stats(HP_MAX, 3*hp_max/2)
		#logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
	elif effect == "MAX_MP_DOWN":
		var mp_max = self.get_max_mp()
		var mp = self.get_mp()
		self.set_stats(MP_MAX, 3*mp_max/2)
		#logs.display_text(target.get_name()+" Perdeu um terço da vida maxima")
	elif effect == "CURSE":
		var hp = self.get_health()
		var agi = self.get_agi()
		var atk = self.get_atk()
		var atkm = self.get_atkm()
		var def = self.get_def()
		var defm = self.get_defm()
		var acc = self.get_acc()
		self.set_stats(HP, hp*2)
		self.set_stats(AGI, agi*2)
		self.set_stats(ATK, atk*2)
		self.set_stats(ATKM, atkm*2)
		self.set_stats(DEF, def*2)
		self.set_stats(DEFM, defm*2)
		self.set_stats(ACC, acc*2)
		#logs.display_text(target.get_name()+" foi amaldiçoado. todos seus effect foram reduzidos pela metade")
	elif effect == "BERSERK":
		var atk = self.get_atk()
		self.set_stats(ATK, atk - 40)
		#logs.display_text(target.get_name()+" esta fora de controle, atacará qualquer um em sua frente")
	elif effect == "UNDEAD":
		var atk = self.get_atk()
		self.set_stats(ATK, atk + 40)
		#logs.display_text(target.get_name()+" foi zumbificado, atacará qualquer alvo")
	elif effect == "PETRIFY":
		var def = self.get_def()
		var defm = self.get_defm()
		self.set_stats(DEF, 3*def/4)
		self.set_stats(DEFM, defm*2)
			#logs.display_text(target.get_name()+" esta petrificado, não consegue atacar")
	elif effect == "BLIND":
		var acc = self.get_acc()
		self.set_stats(ACC, acc*10)
		#logs.display_text(target.get_name()+" teve a visão comprometida, não consegue acertar seus alvos")
	elif effect == "KO":
		dead = false
		self.graphics.revive()
	if status.has(effect):
		status.erase(effect)

func add_status(effect, atkm, turns):
	if effect == "KO":
		status = {}
		dead = true
	status[effect] = [turns, atkm]

func decrement_turns():
	for st in status:
		if st != "KO" and st != "HP_CRITICAL" and st != "TRAPPED" and st != "FLOAT" and st != "UNDEAD":
			status[st][0] -= 1
			if status[st][0] == 0:
				status.erase(st)

func take_damage(type, damage):
	var dmg = 0
	var resistance = 1.0
	if type == PHYSIC:
		dmg = damage - stats[DEF]
	elif type == MAGIC:
		dmg = damage - stats[DEFM]
	else:
		dmg = damage - stats[DEFM]
		resistance = resist[elem[type]]
		dmg = dmg*resistance
	if dmg < 0 and resistance == 1.0:
		dmg = 0
	#set_stats(HP, get_health()-dmg)
	stats[HP] = get_health() - dmg
	self.graphics.take_damage(0, dmg)
	if get_health() < 0.2*get_max_health() and get_health() > 0:
		self.add_status("HP_CRITICAL", 0, 999)
	if get_health() <= 0:
		self.add_status("KO", 0, 999)
		self.remove_status("HP_CRITICAL")
	return dmg

func is_dead():
	return dead

func set_stats(stat, value):
	var ret = 0
	if stat == HP:
		if get_health() +  value > get_max_health():
			ret = get_max_health() - get_health()
			value = get_max_health()
	self.stats[stat] = value
	return ret

func get_graphics():
	return self.graphics

func get_skills():
	return self.skills

func get_name():
	return self.nome

func get_pos():
	return self.position
	
func set_pos(pos):
	self.position = pos

func get_stats(stat):
	return self.stats[stat]

func get_health():
	return self.stats[HP]

func get_max_health():
	return self.stats[HP_MAX]

func get_max_mp():
	return self.stats[MP_MAX]

func get_mp():
	return self.stats[MP]

func get_atk():
	return self.stats[ATK]

func get_atkm():
	return self.stats[ATKM]

func get_def():
	return self.stats[DEF]

func get_defm():
	return self.stats[DEFM]

func get_agi():
	return self.stats[AGI]

func get_acc():
	return self.stats[ACC] 

func get_eva():
	return self.stats[EVA] 

func get_lck():
	return self.stats[LCK]