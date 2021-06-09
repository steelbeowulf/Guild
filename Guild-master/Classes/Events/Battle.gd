extends "Event.gd"

var enemies : Array
var bgm : String
var background : String

func _init(enemies_arg: Array, background_arg: String, bgm_arg: String):
	self.enemies = enemies_arg
	self.background = background_arg
	self.bgm = bgm_arg
	self.type = "BATTLE"

func get_enemies():
	return self.enemies

func get_background():
	return self.background

func get_bgm():
	return self.bgm