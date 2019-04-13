extends "res://Entity.gd"

func _init(valores,  pos, identificacao, habilidades):
	self.stats = valores
	self.alive = true
	self.position = pos
	self.nome = identificacao
	self.skills = habilidades

func get_skills():
	return self.skills