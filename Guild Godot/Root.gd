extends Node2D

# State variables
onready var STATE = "Map"
onready var char_screen = -1 #0 skill, 1 equip, 2 status, 3 tree
onready var map = null

# Shortcut variables
onready var menu = get_node("Menu_Area/Menu")
onready var save = load("res://Pause/Save.tscn")
onready var itens = load("res://Pause/Itens.tscn")
onready var use_itens = load("res://Pause/ItemUse.tscn")
onready var use_skills = load("res://Pause/SkillUse.tscn")
onready var status = load("res://Pause/Status.tscn")
onready var options = load("res://Pause/Options.tscn")
onready var skills = load("res://Pause/Skills.tscn")


# Loads the correct map
func _ready():
	var start = load("res://Overworld/Demo_Area/Map"+str(GLOBAL.MAP)+".tscn")
	self.add_child(start.instance())
	map = get_node("Map"+str(GLOBAL.MAP))


# Watches for inputs and deals with state changes
func _process(delta):
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", TEXT.get_font())
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
		for c in $Menu_Area/SubMenus.get_children():
			c.free()
		menu.show()
		menu.give_focus()
	# Cheap hack to test money
	elif Input.is_action_just_pressed("debug"):
		if(menu.get_focus_owner()):
			print(menu.get_focus_owner().get_name())


# Opens the main pause menu (pauses map)
func open_menu():
	AUDIO.play_bgm("MAP_THEME", true, -5)
	menu.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	menu.enter(GLOBAL.ALL_PLAYERS)
	STATE = "Menu"
	get_tree().paused = true


# Closes the main pause menu (unpauses map)
func close_menu():
	AUDIO.play_bgm("MAP_THEME", true, 0)
	for c in $Menu_Area.get_children():
		c.hide()
	menu.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	STATE = "Map"
	get_tree().paused = false


func player_clicked(num):
	if char_screen == -1:
		# TODO: change lanes somehow
		pass
	elif char_screen == 0:
		# TODO: skill screen
		pass
	elif char_screen == 1:
		# TODO: equip screen
		pass
	elif char_screen == 2:
		open_status(num)
	elif char_screen == 3:
		# TODO: job tree screen
		pass


# Opens the save submenu
func open_save():
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(save.instance())
	get_node("Menu_Area/SubMenus/Save").show()
	get_node("Menu_Area/SubMenus/Save").remove_focus()


# Opens the options submenu
func open_options():
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(options.instance())
	get_node("Menu_Area/SubMenus/Options").show()


# Opens the inventory submenu
func open_inventory():
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(itens.instance())
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").just_entered()
	get_node("Menu_Area/SubMenus/Itens").give_focus()


# Opens the inventory submenu
func back_to_inventory():
	get_node("Menu_Area/SubMenus/ItemUse").hide()
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").just_entered()
	get_node("Menu_Area/SubMenus/Itens").give_focus()

# Opens the skill submenu
func back_to_skills(id):
	get_node("Menu_Area/SubMenus/SkillUse").hide()
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").give_focus()

func open_skills(id):
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(skills.instance())
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").enter()
	get_node("Menu_Area/SubMenus/Skills").give_focus()

# Toggles status submenu
func toggle_status():
	char_screen = 2
	menu.force_char_focus()


# Opens the status submenu
func open_status(char_id):
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(status.instance())
	get_node("Menu_Area/SubMenus/Status").show()
	get_node("Menu_Area/SubMenus/Status").enter(char_id)

# Opens the use item submenu
func use_item(item):
	get_node("Menu_Area/SubMenus/Itens").hide()
	get_node("Menu_Area/SubMenus").add_child(use_itens.instance())
	get_node("Menu_Area/SubMenus/ItemUse").show()
	get_node("Menu_Area/SubMenus/ItemUse").give_focus()
	get_node("Menu_Area/SubMenus/ItemUse").enter(item)

# Opens the use skill submenu
func use_skill(name, playerid):
	get_node("Menu_Area/SubMenus/Skills").hide()
	get_node("Menu_Area/SubMenus").add_child(use_skills.instance())
	get_node("Menu_Area/SubMenus/SkillUse").show()
	get_node("Menu_Area/SubMenus/SkillUse").give_focus()
	get_node("Menu_Area/SubMenus/SkillUse").enter(name, playerid)

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