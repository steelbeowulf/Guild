extends Node

var resolution = 0
var mode = 0

var common_res = [480, 540, 600, 660, 720, 1080, 1440, 2160]

var res_opts = []
var res_vecs = []
var mode_opts = ["Windowed", "Full Screen"]

# Called when the node enters the scene tree for the first time.
func _ready():
	var ASPECT_RATIO = 16.0/10.0
	var max_res = OS.get_screen_size().y
	var i = 0
	while common_res[i] <= max_res:
		var res = Vector2(ASPECT_RATIO*common_res[i], common_res[i])
		res_vecs.append(res)
		res_opts.append(str(res.x)+"x"+str(res.y))
		i += 1
	resolution = i-1
	set_resolution(resolution)


func get_current_res():
	return resolution


func get_modes():
	return mode_opts

func get_available_resolutions():
	return res_opts

func set_resolution(ID):
	resolution = ID
	OS.set_window_size(res_vecs[ID])

func set_mode(ID):
	if ID == 0:
		mode = 0
		OS.set_window_fullscreen(false)
	elif ID == 1:
		mode = 1
		OS.set_window_fullscreen(true)
