extends Node

var nome
var stats
var buffs
var alive
var health
var position
var classe

func _init(valores, vida, pos, identificacao):
	stats = valores
	alive = true
	health = vida
	position = pos
	nome = identificacao