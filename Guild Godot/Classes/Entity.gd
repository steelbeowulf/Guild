extends "Stats.gd"

var id
var nome
var stats
var buffs
var alive
var health
var position
var classe
var skills
var status = {}
var dead = false

func get_status():
	return status

func remove_status(effect):
	stats.erase(effect)

func add_status(effect, atkm, turns):
	#print("adding status "+effect)
	status[effect] = [turns, atkm]
	if effect == "KO":
		dead = true
	#print(status)

func decrement_turns():
	for st in status:
		if st != "KO" and st != "HP_CRITICAL" and st != "TRAPPED" and st != "FLOAT" and st != "UNDEAD":
			status[st][0] -= 1
			if status[st][0] == 0:
				status.erase(st)

func take_damage(type, damage):
	#print(nome+" TOMOU "+str(damage - stats[DEF])+" DE DANO!")
	var dmg = 0
	if type == PHYSIC:
		dmg = damage - stats[DEF]
	elif type == MAGIC:
		dmg = damage - stats[DEFM]
	#print("dmg is "+str(dmg))
	#print("stats[def] is"+str(stats[DEF]))
	#print("value is"+str(damage))
	if dmg < 0:
		dmg = 0
	set_stats(HP, get_health()-dmg)
	if get_health() < 0.2*get_max_health():
		self.add_status("HP_CRITICAL", 0, 999)
	return dmg

func is_dead():
	return dead

func set_stats(stat, value):
	self.stats[stat] = value

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

func get_lck():
	return self.stats[LCK]