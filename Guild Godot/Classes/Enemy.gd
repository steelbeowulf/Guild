extends "Entity.gd"

func _init(valores, identificacao, habilidades):
	self.classe = "boss"
	self.stats = valores
	self.alive = true
	self.position = 0
	self.nome = identificacao
	self.skills = habilidades