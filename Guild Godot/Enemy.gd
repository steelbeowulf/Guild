extends "res://Entity.gd"

func _init(valores, vida, pos, identificacao):
	self.classe = "boss"
	self.stats = valores
	self.alive = true
	self.health = vida
	self.position = pos
	self.nome = identificacao
	self.multiplier = 1