extends Node

var nome
var quantity
var effect = [] #["MP", +10, PHYS, 5]
var status = [] #causa confuse [true, "Confuse"]

func _init(name, quant, efeito, statusEffects):
	self.nome = name
	self.quantity = quant
	self.effect = efeito
	self.status = statusEffects
