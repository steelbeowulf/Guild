extends "Entity.gd"

func _init(valores, pos, identificacao, habilidades):
	self.classe = "boss"
	self.stats = valores
	self.alive = true
	self.position = pos
	self.nome = identificacao
	self.skills = habilidades