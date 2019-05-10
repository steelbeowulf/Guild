extends Node

var nome
var quantity
var type #Offensive, Defensive, Healing
var target #Individual, Lane, All
var effect = [] #["MP", +10, PHYS, 5]
var status = [] #causa confuse [true, "Confuse"]

func _init(name, quant, targ, tipo, efeito, statusEffects):
	self.nome = name
	self.quantity = quant
	self.target = targ
	self.type = tipo
	self.effect = efeito
	self.status = statusEffects
	
func get_target():
	return target
	
func get_cost():
	return quantity
