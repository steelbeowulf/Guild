extends "Entity.gd"

var hate = []
var multiplier = [0.5, 1.0, 3.0]

func _init(id, lv, experience, img, valores,  pos, identificacao, habilidades, resistances):
	self.id = id
	self.sprite = img
	self.level = int(lv)
	self.xp = int(experience)
	self.stats = valores
	self.alive = true
	self.position = pos
	self.nome = identificacao
	self.skills = habilidades
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0

func get_skills():
	return self.skills
	
func get_hate():
	return self.hate

func zero_hate():
	for i in range(len(hate)):
		hate[i] = 0

func reset_hate():
	hate = []

func update_hate(dmg, enemy):
	self.hate[enemy] += multiplier[position]*abs(dmg)
	return self.hate
