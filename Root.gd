extends Node2D

# State variables
onready var STATE = "Map"
onready var char_screen = -1 #0 skill, 1 equip, 2 status, 3 tree
onready var map = null

# Shortcut variables
onready var menu = get_node("Menu_Area/Menu")
onready var shop = get_node("Menu_Area/Shop")
onready var save = load("res://Pause/Save.tscn")
onready var itens = load("res://Pause/Itens.tscn")
onready var use_itens = load("res://Pause/ItemUse.tscn")
onready var use_skills = load("res://Pause/SkillUse.tscn")
onready var status = load("res://Pause/Status.tscn")
onready var options = load("res://Pause/Options.tscn")
onready var skills = load("res://Pause/Skills.tscn")


# Loads the correct map
func _ready():
	#var start = load("res://Overworld/Demo_Area/Map"+str(GLOBAL.MAP)+".tscn")
	var start = load("res://Overworld/Hub/Hub.tscn")
	self.add_child(start.instance())
	map = get_node("Hub")
	#set_effect(GLOBAL.MAP)


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
	elif Input.is_action_just_pressed("ui_cancel") and STATE == "Submenu":
		return_menu()
	#elif Input.is_action_just_pressed("ui_cancel") and STATE == "StatusSubmenu":
	#	print("happenedagain")
	#	return_menu()
	elif Input.is_action_just_pressed("ui_cancel") and STATE == "Menu":
		close_menu()
	# Cheap hack to test money
	elif Input.is_action_just_pressed("debug"):
		GLOBAL.gold += 100
		if(menu.get_focus_owner()):
			print(menu.get_focus_owner().get_name())
		elif(shop.get_focus_owner()):
			print(shop.get_focus_owner().get_name())


# Opens the main pause menu (pauses map)
func open_menu():
	AUDIO.play_bgm("MAP_THEME", true, -8)
	menu.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	menu.enter(GLOBAL.PLAYERS)
	STATE = "Menu"
	get_tree().paused = true

# Opens shop and pauses map
func open_shop(id: int):
	AUDIO.play_bgm("MAP_THEME", true, -8)
	shop.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	shop.enter(id)
	STATE = "Shop"
	get_tree().paused = true

# Closes shop menu(unpauses map)
func close_shop():
	AUDIO.play_bgm("MAP_THEME", true, -4)
	shop.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	STATE = "Map"
	get_tree().paused = false

# Closes the main pause menu (unpauses map)
func close_menu():
	AUDIO.play_bgm("MAP_THEME", true, -4)
	for c in $Menu_Area.get_children():
		c.hide()
	menu.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	STATE = "Map"
	get_tree().paused = false

func return_menu():
	for c in $Menu_Area/SubMenus.get_children():
		print(c)
		c.queue_free()
	menu.enter(GLOBAL.PLAYERS)
	menu.show()
	menu.give_focus()
	STATE = "Menu"

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
	STATE = "SaveSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(save.instance())
	get_node("Menu_Area/SubMenus/Save").show()
	get_node("Menu_Area/SubMenus/Save").remove_focus()


# Opens the options submenu
func open_options():
	STATE = "Submenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(options.instance())
	get_node("Menu_Area/SubMenus/Options").show()


# Opens the inventory submenu
func open_inventory():
	STATE = "ItemSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(itens.instance())
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").just_entered()
	get_node("Menu_Area/SubMenus/Itens").give_focus()


# Opens the inventory submenu
func back_to_inventory():
	STATE = "ItemSubmenu"
	get_node("Menu_Area/SubMenus/ItemUse").hide()
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").just_entered()
	get_node("Menu_Area/SubMenus/Itens").give_focus()

# Opens the skill submenu
func back_to_skills(id):
	STATE = "SkillSubmenu"
	get_node("Menu_Area/SubMenus/SkillUse").hide()
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").give_focus()

func open_skills(id):
	STATE = "SkillSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(skills.instance())
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").enter()

func open_equips(id):
	STATE = "EquipSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(skills.instance())
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").enter()

# Toggles status submenu
func toggle_status():
	char_screen = 2
	menu.force_char_focus()


# Opens the status submenu
func open_status(char_id):
	STATE = "StatusSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(status.instance())
	get_node("Menu_Area/SubMenus/Status").show()
	get_node("Menu_Area/SubMenus/Status").enter(char_id)

# Opens the use item submenu
func use_item(item):
	STATE = "ItemUseSubmenu"
	get_node("Menu_Area/SubMenus/Itens").hide()
	get_node("Menu_Area/SubMenus").add_child(use_itens.instance())
	get_node("Menu_Area/SubMenus/ItemUse").show()
	get_node("Menu_Area/SubMenus/ItemUse").give_focus()
	get_node("Menu_Area/SubMenus/ItemUse").enter(item)

# Opens the use skill submenu
func use_skill(skill, player):
	STATE = "SkillUseSubmenu"
	get_node("Menu_Area/SubMenus/Skills").hide()
	get_node("Menu_Area/SubMenus").add_child(use_skills.instance())
	get_node("Menu_Area/SubMenus/SkillUse").show()
	get_node("Menu_Area/SubMenus/SkillUse").give_focus()
	get_node("Menu_Area/SubMenus/SkillUse").enter(skill, player)

# Transitions from current area to next area
func transition(next, fake=false):
	var new = load("res://Overworld/Demo_Area/Map"+str(next)+".tscn")
	GLOBAL.MAP = next
	set_effect(GLOBAL.MAP)
	#call_deferred("add_child", new.instance())
	self.add_child(new.instance())
	if map:
		remove_child(map)
		map.queue_free()
	GLOBAL.TRANSITION = -1
	if not fake:
		GLOBAL.TRANSITION = GLOBAL.MAP
	map = get_node("Map"+str(next))

var darkness = [
	0,
	0,#1
	0,#2
	0,#3
	0,#4
	0,#5
	.05,#6
	.05,#7
	.1,#8
	.1,#9
	.1,#10
	.2,#11
	.2,#12
	.3,#13
	.4,#14
	.4,#15
	.4,#16
	.4,#17
	.4,#18
	.4,#19
	.4,#20
	.4,#21
	.5,#22
	0,#23
	0,#24
	.15#25
]

func set_effect(map):
	$Effects/Corruption.color = Color(.05, 0, .15, darkness[map])

# Adds to the total playtime (in seconds)
func _on_Timer_timeout():
	GLOBAL.playtime += 1
