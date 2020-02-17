extends Node2D

onready var STATE = "Map"
onready var menu = get_node("Menu_Area/Menu")
onready var battle_scene = load("res://Battle/Battle.tscn")
onready var lv_up_scene = load("res://Battle/Level Up.tscn")
var map = null

# Called when the node enters the scene tree for the first time.
func _ready():


	var start = load("res://Overworld/Demo_Area/Map"+str(GLOBAL.MAP)+".tscn")
	self.add_child(start.instance())
	map = get_node("Map"+str(GLOBAL.MAP))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if STATE == "Menu":
		menu.update_info()
	if Input.is_action_just_pressed("menu") and STATE == "Map":
		open_menu()
	elif Input.is_action_just_pressed("menu") and STATE == "Menu":
		close_menu()
	elif Input.is_action_just_pressed("ui_cancel") and STATE == "Menu":
		for c in get_node("Menu_Area").get_children():
			c.hide()
		menu.show()
		menu.give_focus()
	elif Input.is_action_just_pressed("ui_focus_next"):
		GLOBAL.gold += 100

func open_menu():
	menu.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	menu.enter(GLOBAL.ALL_PLAYERS)
	STATE = "Menu"
	get_tree().paused = true

func close_menu():
	menu.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	STATE = "Map"
	get_tree().paused = false

func open_save():
	menu.hide()
	get_node("Menu_Area/Save").show()
	get_node("Menu_Area/Save").load_saves(LOADER.load_save_info())
	get_node("Menu_Area/Save").remove_focus()

func open_inventory():
	menu.hide()
	get_node("Menu_Area/Itens").show()


func get_area():
	return area

var area = "Map1"

func transition(next):
	var new = load("res://Overworld/Demo_Area/Map"+str(next)+".tscn")
	if map:
		remove_child(map)
		map.queue_free()
	GLOBAL.MAP = next
	self.add_child(new.instance())
	map = get_node("Map"+str(next))
	area = "Map"+str(next)

func _on_Timer_timeout():
	GLOBAL.playtime += 1
