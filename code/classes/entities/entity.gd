class_name Entity
extends STATS

enum { PHYSIC, MAGIC, FIRE, WATER, ELECTRIC, ICE, EARTH, WIND, HOLY, DARKNESS }
enum { HP, HP_MAX, MP, MP_MAX, ATK, ATKM, DEF, DEFM, AGI, ACC, EVA, LCK }

var id
var index
var level
var exp
var sprite
var animations
var name
var stats
var buffs
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
var elem = {
	0: "PHYSIC",
	1: "MAGIC",
	2: "FIRE",
	3: "WATER",
	4: "ELECTRIC",
	5: "ICE",
	6: "EARTH",
	7: "WIND",
	8: "HOLY",
	9: "DARKNESS"
}


func die():
	print("[ENTITY] " + self.name + " has died!")
	self.set_stats(HP, 0)
	self.remove_all_status()
	self.status["KO"] = [9999, 9999]
	self.dead = true


func get_level():
	return level


func get_status():
	return status


func remove_all_status():
	status = {}


func remove_status(effect):
	print("Will remove status " + str(effect) + " on " + str(self.name))
	if effect == "SLOW":
		var agi = self.get_agi()
		self.set_stats(AGI, agi * 2)
	elif effect == "HASTE":
		var agi = self.get_agi()
		self.set_stats(AGI, agi / 2)
	elif effect == "MAX_HP_DOWN":
		var hp_max = self.get_max_health()
		var hp = self.get_health()
		self.set_stats(HP_MAX, 3 * hp_max / 2)
	elif effect == "MAX_MP_DOWN":
		var mp_max = self.get_max_mp()
		var mp = self.get_mp()
		self.set_stats(MP_MAX, 3 * mp_max / 2)
	elif effect == "CURSE":
		var hp = self.get_health()
		var agi = self.get_agi()
		var atk = self.get_atk()
		var atkm = self.get_atkm()
		var def = self.get_def()
		var defm = self.get_defm()
		var acc = self.get_acc()
		self.set_stats(HP, hp * 2)
		self.set_stats(AGI, agi * 2)
		self.set_stats(ATK, atk * 2)
		self.set_stats(ATKM, atkm * 2)
		self.set_stats(DEF, def * 2)
		self.set_stats(DEFM, defm * 2)
		self.set_stats(ACC, acc * 2)
	elif effect == "BERSERK":
		var atk = self.get_atk()
		self.set_stats(ATK, atk - 40)
	elif effect == "UNDEAD":
		var atk = self.get_atk()
		self.set_stats(ATK, atk + 40)
	elif effect == "PETRIFY":
		var def = self.get_def()
		var defm = self.get_defm()
		self.set_stats(DEF, 3 * def / 4)
		self.set_stats(DEFM, defm * 2)
	elif effect == "BLIND":
		var acc = self.get_acc()
		self.set_stats(ACC, acc * 10)
	elif effect == "KO":
		ressurect()
	if status.has(effect):
		status.erase(effect)
	if GLOBAL.status.has(effect):
		self.graphics.remove_aura()


func add_status(effect, atkm, turns):
	if effect == "KO":
		self.die()
	if GLOBAL.status.has(effect) and LOCAL.in_BATTLE:
		self.graphics.set_aura(GLOBAL.status[effect])
	status[effect] = [turns, atkm]


func decrement_turns():
	for st in status:
		if (
			st != "KO"
			and st != "HP_CRITICAL"
			and st != "TRAPPED"
			and st != "FLOAT"
			and st != "UNDEAD"
		):
			status[st][0] -= 1
			if status[st][0] == 0:
				remove_status(st)


func take_damage(type, damage):
	print("[ENTITY] Taking damage " + str(type) + ", " + str(damage))
	var dmg = 0
	var resistance = 1.0
	if type == PHYSIC:
		dmg = damage - stats[DEF]
	elif type == MAGIC:
		dmg = damage - stats[DEFM]
	else:
		dmg = damage - stats[DEFM]
		resistance = resist[elem[type]]
		dmg = dmg * resistance
	if dmg < 0 and resistance == 1.0:
		dmg = 0
	#set_stats(HP, get_health()-dmg)
	stats[HP] = get_health() - dmg
	#self.graphics.take_damage(0, dmg)
	if get_health() < 0.2 * get_max_health() and get_health() > 0:
		self.add_status("HP_CRITICAL", 0, 999)
	if get_health() <= 0:
		print(self.name + " IS GOING TO DIIE")
		self.die()
	return dmg


func is_critical_health():
	return get_health() < 0.2 * get_max_health() and get_health() > 0


func is_dead():
	return dead


func set_stats(stat, value):
	var ret = 0
	self.stats[stat] = value
	return ret


func get_graphics():
	return self.graphics


func get_skills():
	return self.skills


func get_skill(id):
	return self.skills[id]


func get_name():
	return self.name


func get_pos():
	return self.position


func set_pos(pos):
	self.position = pos


func get_stats(stat):
	if typeof(stat) == TYPE_STRING:
		stat = DSTAT[stat]
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
