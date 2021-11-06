class_name Entity
extends STATS

enum { PHYSIC, MAGIC, FIRE, WATER, ELECTRIC, ICE, EARTH, WIND, HOLY, DARKNESS }
enum { HP, HP_MAX, MP, MP_MAX, ATK, ATKM, DEF, DEFM, AGI, ACC, EVA, LCK }

var id: int
var index: int
var level: int setget set_level, get_level
var experience: int setget set_experience, get_experience
var sprite
var animations
var name: String setget , get_name
var stats: Array
var position setget set_position, get_position
var skills: Array setget , get_skills
var graphics: BattleEntity setget set_graphics, get_graphics
var status: Dictionary = {} setget , get_status
var dead: bool = false
var resist: Dictionary = {}
var type: String


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

########### Getters/Setters

func get_name():
	return self.name

func get_position():
	return self.position

func set_position(pos):
	self.position = pos

func set_level(lv: int):
	self.level = lv

func get_level():
	return level

func set_experience(xp: int):
	self.experience = xp

func get_experience():
	return experience

func set_graphics(graphics: BattleEntity):
	self.graphics = graphics

func get_graphics():
	return self.graphics

func get_skills():
	return self.skills

func get_skill(id: int):
	return self.skills[id]

func get_stat(stat):
	if typeof(stat) == TYPE_STRING:
		stat = DSTAT[stat]
	return self.stats[stat]

func set_stat(stat, value):
	var ret = 0
	self.stats[stat] = value
	return ret

func get_status():
	return status

########### Entity Logic

func is_critical_health():
	return get_stat("HP") < 0.2 * get_stat("HP_MAX") and get_stat("HP") > 0

func is_dead():
	return dead

func die():
	print("[ENTITY] " + self.name + " has died!")
	self.set_stat(HP, 0)
	self.remove_all_status()
	self.status["KO"] = [9999, 9999]
	self.dead = true

func add_status(effect: str, atkm: int, turns: int):
	if effect == "KO":
		self.die()
	if GLOBAL.status.has(effect) and LOCAL.in_BATTLE:
		self.graphics.set_aura(GLOBAL.status[effect])
	status[effect] = [turns, atkm]

func remove_status(effect: str):
	print("Will remove status " + str(effect) + " on " + str(self.name))
	if effect == "SLOW":
		var agi = self.get_stat("AGI")
		self.set_stat(AGI, agi * 2)
	elif effect == "HASTE":
		var agi = self.get_stat("AGI")
		self.set_stat(AGI, agi / 2)
	elif effect == "MAX_HP_DOWN":
		var hp_max = self.get_stat("HP_MAX")
		var hp = self.get_stat("HP")
		self.set_stat(HP_MAX, 3 * hp_max / 2)
	elif effect == "MAX_MP_DOWN":
		var mp_max = self.get_stat("MP_MAX")
		var mp = self.get_stat("MP")
		self.set_stat(MP_MAX, 3 * mp_max / 2)
	elif effect == "CURSE":
		var hp = self.get_stat("HP")
		var agi = self.get_stat("AGI")
		var atk = self.get_stat("ATK")
		var atkm = self.get_stat("ATKM")
		var def = self.get_stat("DEF")
		var defm = self.get_stat("DEFM")
		var acc = self.get_stat("ACC")
		self.set_stat(HP, hp * 2)
		self.set_stat(AGI, agi * 2)
		self.set_stat(ATK, atk * 2)
		self.set_stat(ATKM, atkm * 2)
		self.set_stat(DEF, def * 2)
		self.set_stat(DEFM, defm * 2)
		self.set_stat(ACC, acc * 2)
	elif effect == "BERSERK":
		var atk = self.get_stat("ATK")
		self.set_stat(ATK, atk - 40)
	elif effect == "UNDEAD":
		var atk = self.get_stat("ATK")
		self.set_stat(ATK, atk + 40)
	elif effect == "PETRIFY":
		var def = self.get_stat("DEF")
		var defm = self.get_stat("DEFM")
		self.set_stat(DEF, 3 * def / 4)
		self.set_stat(DEFM, defm * 2)
	elif effect == "BLIND":
		var acc = self.get_stat("ACC")
		self.set_stat(ACC, acc * 10)
	elif effect == "KO":
		ressurect()
	if status.has(effect):
		status.erase(effect)
	if GLOBAL.status.has(effect):
		self.graphics.remove_aura()

func remove_all_status():
	status = {}

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
	#set_stat(HP, get_stat("HP")-dmg)
	stats[HP] = get_stat("HP") - dmg
	#self.graphics.take_damage(0, dmg)
	if get_stat("HP") < 0.2 * get_stat("HP_MAX") and get_stat("HP") > 0:
		self.add_status("HP_CRITICAL", 0, 999)
	if get_stat("HP") <= 0:
		print(self.name + " IS GOING TO DIIE")
		self.die()
	return dmg
