class_name Equip

const equip_dict = {'HEAD':0, 'BODY':1, 'HANDS':2, 'ACCESSORY':3}

var id
var nome
var quantity
var type #Melee, Ranged, Magic
var job #Knight, Rogue, Cleric
var location #Body, Head, Accessory, Hands
var effect = [] #["ATK", +25, PHYS]
var status = [] #causa confuse [true, "Confuse"]
var img


func _init(id: int, name: String, tipo: String, local: String,
	classe: String, efeito: Array, statusEffects: Array, preco: int, img: Dictionary):
	self.id = id
	self.nome = name
	self.type = tipo
	self.job = classe
	self.location = local
	self.quantity = preco
	self.effect = efeito
	self.status = statusEffects
	self.img = img
	
func get_job():
	return job

func get_type():
	return type

func get_location():
	return location

func get_name():
	return nome

func get_effects():
	return effect

func get_effect(stat_id: int):
	for eff in effect:
		if eff.get_id() == stat_id:
			return eff.get_value()
	return 0

func get_status():
	return status

func get_cost():
	return quantity

func get_slot():
	return equip_dict[self.location]

func _duplicate():
	var new_effects = [] + self.effect
	var new_status = [] + self.status
	return self.get_script().new(self.id, self.nome, self.type, self.location, 
	self.job, new_effects, new_status, self.quantity, self.img)