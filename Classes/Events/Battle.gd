extends "Event.gd"

var enemies : Array
var bgm : String
var is_boss: bool
var background : String

func _init(enemies_arg: Array, background_arg: String, bgm_arg: String, is_boss_arg = false):
	self.enemies = enemies_arg
	self.background = background_arg
	self.bgm = bgm_arg
	self.is_boss = is_boss_arg