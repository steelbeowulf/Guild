extends "res://stats.gd"

var nome
var stats
var buffs
var alive
var health
var position
var classe
var skills

#func _init(valores, vida, pos, identificacao):
#	stats = valores
#	alive = true
#	health = vida
#	position = pos
#	nome = identificacao
#	set_multiplier(pos, 0, 0)

func take_damage(type, damage):
	print(nome+" TOMOU "+str(damage - stats[DEF])+" DE DANO!")
	if type == PHYSIC:
		self.stats[HP] -= damage - stats[DEF]
	elif type == MAGIC:
		self.stats[HP] -= damage - stats[DEFM]
	print(nome+ " AGORA TEM "+str(stats[HP])+" DE VIDA!")

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

func get_lck():
	return self.stats[LCK]