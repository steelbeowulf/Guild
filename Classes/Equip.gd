extends Node
class_name Equip

var id
var nome
var type #Melee, Ranged, Magic
var classe #Individual, Lane, All
var effect = [] #["ATK", +25, PHYS]
var status = [] #causa confuse [true, "Confuse"]
var img

func _init(id, name, quant, targ, tipo, efeito, statusEffects, img, anim):
	self.id = id
	self.nome = name
	self.type = tipo
	self.job = classe
	self.effect = efeito
	self.status = statusEffects
	self.img = img
	
func get_job():
	return classe

func get_type():
	return type

func get_name():
	return nome

func get_effects():
	return effect

func get_status():
	return status