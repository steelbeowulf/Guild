extends Node2D

# State variables
onready var STATE = "Map"
onready var map = null

# Shortcut variables
onready var menu = get_node("Menu_Area/Menu")
onready var save = load("res://Pause/Save.tscn")
onready var itens = load("res://Pause/Itens.tscn")


# Loads the correct map
func _ready():
	var start = load("res://Overworld/Demo_Area/Map"+str(GLOBAL.MAP)+".tscn")
	self.add_child(start.instance())
	map = get_node("Map"+str(GLOBAL.MAP))


# Watches for inputs and deals with state changes
func _process(delta):
	# Updates playtime while on menu screen
	if STATE == "Menu":
		menu.update_info()
	# Opens menu from the map
	if Input.is_action_just_pressed("menu") and STATE == "Map":
		open_menu()
	# Closes menu and return to map
	elif Input.is_action_just_pressed("menu") and STATE == "Menu":
		close_menu()
	# Closes submenus and returns to menu
	elif Input.is_action_just_pressed("ui_cancel") and STATE == "Menu":
		#$Menu_Area/SubMenus.hide()
		for c in $Menu_Area/SubMenus.get_children():
			c.free()
		menu.show()
		menu.give_focus()
	# Cheap hack to test money
	elif Input.is_action_just_pressed("debug"):
		print(menu.get_focus_owner())


# Opens the main pause menu (pauses map)
func open_menu():
	menu.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	menu.enter(GLOBAL.ALL_PLAYERS)
	STATE = "Menu"
	get_tree().paused = true


# Closes the main pause menu (unpauses map)
func close_menu():
	for c in $Menu_Area.get_children():
		c.hide()
	menu.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	STATE = "Map"
	get_tree().paused = false


# Opens the save submenu
func open_save():
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(save.instance())
	get_node("Menu_Area/SubMenus/Save").show()
	get_node("Menu_Area/SubMenus/Save").enter()
	get_node("Menu_Area/SubMenus/Save").remove_focus()


# Opens the inventory submenu
func open_inventory():
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(itens.instance())
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").give_focus()


# Transitions from current area to next area
# TODO: fix crash when map changes are quick
func transition(next, fake=false):
	var new = load("res://Overworld/Demo_Area/Map"+str(next)+".tscn")
	if map:
		remove_child(map)
		map.queue_free()
	GLOBAL.TRANSITION = -1
	if not fake:
		GLOBAL.TRANSITION = GLOBAL.MAP
	GLOBAL.MAP = next
	self.add_child(new.instance())
	map = get_node("Map"+str(next))


# Adds to the total playtime (in seconds)
func _on_Timer_timeout():
	GLOBAL.playtime += 1