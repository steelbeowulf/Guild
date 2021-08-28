extends Node

var font_size = "21"
var text_speed = 10

var size_opts = ["20", "21", "22", "23", "24"]
var size_index = 0

var speed_opts = ["Slow", "Medium", "Fast"]
var speed_vals = [5, 10, 15]
var speed_index = 0

func get_size():
	return font_size

func get_size_id():
	return size_index

func get_speed_id():
	return speed_index

func get_speed():
	return text_speed


func get_size_opts():
	return size_opts


func get_speed_opts():
	return speed_opts


func set_speed(ID):
	speed_index = ID
	text_speed = speed_vals[ID]


func set_size(ID):
	size_index = ID
	font_size = size_opts[ID]
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", get_font())


func get_font():
	return load("res://Assets/Fonts/Font"+font_size+".tres")