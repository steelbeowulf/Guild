class_name Item

var id
var name
var quantity
var type  #Offensive, Defensive, Healing
var target  #Individual, Lane, All
var effect = []  #["MP", +10, PHYS, 5]
var status = []  #causa confuse [true, "Confuse"]
var img
var anim


func _init(id, name, quant, targ, type, efeito, status_effects, img, anim):
	self.id = id
	self.name = name
	self.quantity = quant
	self.target = targ
	self.type = type
	self.effect = efeito
	self.status = status_effects
	self.img = img
	self.anim = anim["skill"]


func get_target():
	return target


func get_type():
	return type


func get_cost():
	return quantity


func get_name():
	return name


func get_effects():
	return effect


func get_status():
	return status


func clone():
	var new_effects = [] + self.effect
	var new_status = [] + self.status
	var new_anim = {"skill": self.anim}
	return self.get_script().new(
		self.id,
		self.name,
		self.quantity,
		self.target,
		self.type,
		new_effects,
		new_status,
		self.img,
		new_anim
	)
