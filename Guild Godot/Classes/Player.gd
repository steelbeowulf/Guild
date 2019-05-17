extends "Entity.gd"

var hate = []
var multiplier = [0.5, 1.0, 3.0]

func _init(valores,  pos, identificacao, habilidades):
	self.stats = valores
	self.alive = true
	self.position = pos
	self.nome = identificacao
	self.skills = habilidades

func get_skills():
	return self.skills
	
func get_hate():
	return self.hate
	
func update_hate(dmg, enemy):
	self.hate[enemy] += multiplier[position]*abs(dmg)
