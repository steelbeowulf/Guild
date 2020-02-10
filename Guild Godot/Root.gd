extends Node2D

onready var STATE = "Map"

# Called when the node enters the scene tree for the first time.
func _ready():
	var start = load("res://Overworld/Demo_Area/Map"+str(GLOBAL.MAP)+".tscn")
	self.add_child(start.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu") and STATE == "Map": 
		get_node("Menu_Area/Menu").show()
		get_child(1).hide_hud()
		get_node("Menu_Area/Camera2D").make_current()
		get_node("Menu_Area/Menu").enter(GLOBAL.ALL_PLAYERS)
		STATE = "Menu"
		get_tree().paused = true
	elif Input.is_action_just_pressed("menu") and STATE == "Menu":
		get_node("Menu_Area/Menu").hide()
		get_child(1).get_node("Party").get_child(0).get_node("Camera2D").make_current()
		get_child(1).show_hud()
		STATE = "Map"
		get_tree().paused = false
	elif Input.is_action_just_pressed("ui_cancel") and STATE == "Menu":
		for c in get_node("Menu_Area").get_children():
			c.hide()
		get_node("Menu_Area/Menu").show()
	elif Input.is_action_just_pressed("ui_focus_next"):
		GLOBAL.gold += 100

func open_save():
	get_node("Menu_Area/Menu").hide()
	get_node("Menu_Area/Save").show()
	get_node("Menu_Area/Save").load_saves(LOADER.load_save_info())
	get_node("Menu_Area/Save").remove_focus()

func get_area():
	return self.get_child(1).get_name()

func transition(next):
	var new = load("res://Overworld/Demo_Area/Map"+str(next)+".tscn")
	get_child(1).queue_free()
	remove_child(get_child(1))
	self.add_child(new.instance())

func _on_Timer_timeout():
	GLOBAL.playtime += 1
