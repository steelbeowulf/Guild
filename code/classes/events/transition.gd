class_name Transition
extends Event

var area: String
var map: int
var position: Vector2


func _init(area_arg: String, map_arg: int, pos_arg: Vector2):
	self.area = area_arg
	self.map = map_arg
	self.position = pos_arg
	self.type = "TRANSITION"


func get_area():
	return self.area


func get_map():
	return self.map


func get_position():
	return self.position
