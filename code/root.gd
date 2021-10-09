extends Node2D

# State variables
onready var state = "Map"
onready var char_screen = -1  #0 skill, 1 equip, 2 status, 3 tree
onready var map = null

# Shortcut variables
onready var menu = get_node("Menu_Area/Menu")
onready var shop = get_node("Menu_Area/Shop")
onready var save = load("res://code/ui/menu/Save.tscn")
onready var itens = load("res://code/ui/menu/Itens.tscn")
onready var use_itens = load("res://code/ui/menu/use_item_screen.tscn")
onready var use_skills = load("res://code/ui/menu/use_skill_screen.tscn")
onready var status = load("res://code/ui/menu/status_screen.tscn")
onready var options = load("res://code/ui/menu/options_screen.tscn")
onready var skills = load("res://code/ui/menu/skills_screen.tscn")
onready var equips = load("res://code/ui/menu/equipment_screen.tscn")
onready var change = load("res://code/ui/menu/party_screen.tscn")

onready var loader = get_node("/root/LOADER")

onready var darkness = [
	0,
	0,  #1
	0,  #2
	0,  #3
	0,  #4
	0,  #5
	.05,  #6
	.05,  #7
	.1,  #8
	.1,  #9
	.1,  #10
	.2,  #11
	.2,  #12
	.3,  #13
	.4,  #14
	.4,  #15
	.4,  #16
	.4,  #17
	.4,  #18
	.4,  #19
	.4,  #20
	.4,  #21
	.5,  #22
	0,  #23
	0,  #24
	.15  #25
]

# Loads the correct map
func _ready():
	var start = load("res://code/maps/" + str(LOCAL.area) + "/Map" + str(LOCAL.map) + ".tscn")
	self.add_child(start.instance())
	map = get_child(get_child_count() - 1)
	set_effect(LOCAL.map)


func change_area(area_name: String, next: int = 1, pos: Vector2 = Vector2(0, 0)):
	print("[ROOT] Changing area! ", area_name)
	if pos != Vector2(0, 0):
		LOCAL.position = pos
	var new = load("res://code/maps/" + area_name + "/Map" + str(next) + ".tscn")
	LOCAL.map = next
	LOCAL.area = area_name
	set_effect(LOCAL.map)
	var area_info = loader.load_area_info(area_name)
	LOCAL.load_enemies(area_info["ENEMIES"])
	LOCAL.load_npcs(area_info["NPCS"])
	self.add_child(new.instance())
	if map:
		map.hide()
		remove_child(map)
		map.queue_free()
	LOCAL.transition = -1
	map = get_child(len(get_children()) - 1)


# Watches for inputs and deals with state changes
func _process(_delta):
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", TEXT.get_font())
	# Updates playtime while on menu screen
	if state == "Menu":
		menu.update_info()
	# Opens menu from the map
	if Input.is_action_just_pressed("menu") and state == "Map":
		open_menu()
	# Closes menu and return to map
	elif Input.is_action_just_pressed("menu") and state == "Menu":
		close_menu()
	# Closes submenus and returns to menu
	elif Input.is_action_just_pressed("ui_cancel") and state == "Submenu":
		return_menu()
	elif Input.is_action_just_pressed("ui_cancel") and state == "Menu":
		close_menu()


# Opens the main pause menu (pauses map)
func open_menu():
	AUDIO.play_bgm("MAP_THEME", true, -8)
	menu.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	menu.enter(GLOBAL.players)
	state = "Menu"
	get_tree().paused = true


# Opens shop and pauses map
func open_shop(shop_event: Event):
	EVENTS.dialogue_ended(true)
	AUDIO.play_bgm("MAP_THEME", true, -8)
	shop.show()
	map.hide_hud()
	get_node("Menu_Area/Camera2D").make_current()
	shop.enter(shop_event)
	state = "Shop"
	get_tree().paused = true
	shop.set_process(true)


# Closes shop menu(unpauses map)
func close_shop():
	AUDIO.play_bgm("MAP_THEME", true, -4)
	shop.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	state = "Map"
	get_tree().paused = false
	shop.set_process(false)


# Closes the main pause menu (unpauses map)
func close_menu():
	AUDIO.play_bgm("MAP_THEME", true, -4)
	for c in $Menu_Area.get_children():
		c.hide()
	menu.hide()
	map.get_node("Party").get_child(0).get_node("Camera2D").make_current()
	map.show_hud()
	state = "Map"
	get_tree().paused = false


func return_menu():
	for c in $Menu_Area/SubMenus.get_children():
		print(c)
		c.queue_free()
	menu.enter(GLOBAL.players)
	menu.show()
	menu.give_focus()
	state = "Menu"


# Opens the save submenu
func open_save():
	state = "SaveSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(save.instance())
	get_node("Menu_Area/SubMenus/Save").show()
	get_node("Menu_Area/SubMenus/Save").remove_focus()


# Opens the options submenu
func open_options():
	state = "Submenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(options.instance())
	get_node("Menu_Area/SubMenus/Options").show()


# Opens the inventory submenu
func open_inventory():
	state = "ItemSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(itens.instance())
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").just_entered()
	get_node("Menu_Area/SubMenus/Itens").give_focus()


func open_change():
	state = "ChangesSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(change.instance())
	get_node("Menu_Area/SubMenus/Change").show()
	get_node("Menu_Area/SubMenus/Change").just_entered()
	get_node("Menu_Area/SubMenus/Change").give_focus()


# Opens the inventory submenu
func back_to_inventory():
	state = "ItemSubmenu"
	get_node("Menu_Area/SubMenus/ItemUse").hide()
	get_node("Menu_Area/SubMenus/Itens").show()
	get_node("Menu_Area/SubMenus/Itens").just_entered()
	get_node("Menu_Area/SubMenus/Itens").give_focus()


# Opens the skill submenu
func back_to_skills(id):
	state = "SkillSubmenu"
	get_node("Menu_Area/SubMenus/SkillUse").hide()
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").give_focus()


func open_skills(id):
	state = "SkillSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(skills.instance())
	get_node("Menu_Area/SubMenus/Skills").show()
	get_node("Menu_Area/SubMenus/Skills").just_entered(id)
	get_node("Menu_Area/SubMenus/Skills").enter()


func open_equips(id):
	state = "EquipSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(equips.instance())
	get_node("Menu_Area/SubMenus/Equips").show()
	get_node("Menu_Area/SubMenus/Equips").just_entered(id)
	get_node("Menu_Area/SubMenus/Equips").enter()


# Toggles status submenu
func toggle_status():
	char_screen = 2
	menu.force_char_focus()


# Opens the status submenu
func open_status(char_id):
	state = "StatusSubmenu"
	menu.hide()
	get_node("Menu_Area/SubMenus").show()
	get_node("Menu_Area/SubMenus").add_child(status.instance())
	get_node("Menu_Area/SubMenus/Status").show()
	get_node("Menu_Area/SubMenus/Status").enter(char_id)


# Opens the use item submenu
func use_item(item):
	state = "ItemUseSubmenu"
	get_node("Menu_Area/SubMenus/Itens").hide()
	get_node("Menu_Area/SubMenus").add_child(use_itens.instance())
	get_node("Menu_Area/SubMenus/ItemUse").show()
	get_node("Menu_Area/SubMenus/ItemUse").give_focus()
	get_node("Menu_Area/SubMenus/ItemUse").enter(item)


# Opens the use skill submenu
func use_skill(skill, player):
	state = "SkillUseSubmenu"
	get_node("Menu_Area/SubMenus/Skills").hide()
	get_node("Menu_Area/SubMenus").add_child(use_skills.instance())
	get_node("Menu_Area/SubMenus/SkillUse").show()
	get_node("Menu_Area/SubMenus/SkillUse").give_focus()
	get_node("Menu_Area/SubMenus/SkillUse").enter(skill, player)


# Transitions from current area to next area
func transition(next, fake = false):
	var new = load("res://code/maps/" + LOCAL.area + "/Map" + str(next) + ".tscn")
	LOCAL.map = next
	set_effect(LOCAL.map)
	#call_deferred("add_child", new.instance())
	self.add_child(new.instance())
	if map:
		remove_child(map)
		map.queue_free()
	LOCAL.transition = -1
	if not fake:
		LOCAL.transition = LOCAL.map
	map = get_node("Map" + str(next))


func set_effect(map):
	$Effects/Corruption.color = Color(.05, 0, .15, darkness[map])


# Adds to the total playtime (in seconds)
func _on_Timer_timeout():
	GLOBAL.playtime += 1
