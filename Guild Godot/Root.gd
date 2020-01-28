extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var start = load("res://Overworld/Map1.tscn")
	self.add_child(start.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"): 
		if not get_tree().paused:
			get_node("Menu_Area").show()
			get_child(1).hide_hud()
			get_node("Menu_Area/Camera2D").make_current()
			get_node("Menu_Area/Menu").enter()
			get_tree().paused = true
		else:
			get_node("Menu_Area").hide()
			get_child(1).get_node("Party").get_child(0).get_node("Camera2D").make_current()
			get_child(1).show_hud()
			get_tree().paused = false

func get_area():
	return self.get_child(1).get_name()
