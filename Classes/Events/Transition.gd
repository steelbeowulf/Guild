extends "Event.gd"

var area : String
var map : String
var position : Vector2

func _init(area_arg: String, map_arg: String, pos_arg: Vector2):
	self.area = area_arg
	self.map = map_arg
	self.position = pos_arg
