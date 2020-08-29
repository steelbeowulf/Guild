extends Node
class_name Item

var id
var nome
var quantity
var type #Offensive, Defensive, Healing
var target #Individual, Lane, All
var effect = [] #["MP", +10, PHYS, 5]
var status = [] #causa confuse [true, "Confuse"]
var img
var anim

func _init(id, name, quant, targ, tipo, efeito, statusEffects, img, anim):
	self.id = id
	self.nome = name
	self.quantity = quant
	self.target = targ
	self.type = tipo
	self.effect = efeito
	self.status = statusEffects
	self.img = img
	self.anim = anim["skill"]
	
func get_target():
	return target

func get_type():
	return type

func get_cost():
	return quantity

func get_name():
	return nome

func get_effects():
	return effect

func get_status():
	return status
