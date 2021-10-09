extends Control
onready var id = -1
onready var location = "OUTSIDE"


func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		AUDIO.play_se("MOVE_MENU")
		enter(int(id + 1) % len(GLOBAL.players))
	elif Input.is_action_just_pressed("ui_left"):
		AUDIO.play_se("MOVE_MENU")
		enter(int(id - 1) % len(GLOBAL.players))
	elif Input.is_action_just_pressed("ui_cancel") and location == "SUBMENU":
		AUDIO.play_se("EXIT_MENU")
		location = "OUTSIDE"
		get_parent().get_parent().get_parent().return_menu()


func enter(player_id):
	print("hello")
	location = "SUBMENU"
	print(player_id)
	id = player_id
	var player = GLOBAL.players[player_id]
	# Sets player name
	$Top_Panel/Char_name.set_text(player.get_name())

	set_overview_info(player)
	set_stats_info(player)
	set_resist_info(player)


# Sets name, exp, lv and hp info
func set_overview_info(player):
	var node = $Overview/Values
	node.get_node("LV").set_text(str(player.level))
	var tmp = str(player.get_health()) + "/" + str(player.get_max_health())
	node.get_node("HP").set_text(tmp)
	tmp = str(player.get_mp()) + "/" + str(player.get_max_mp())
	node.get_node("MP").set_text(tmp)
	tmp = str(player.xp) + "/" + str(((18 / 10) ^ player.level) * 5)
	node.get_node("EXP").set_text(tmp)
	# Needs a portrait
	$Overview/Sprite.set_texture(load(player.portrait))


# Sets stats info
# WARNING: DO NOT CHANGE ORDER
func set_stats_info(player):
	var node = $Columns/Stats/Values.get_children()
	for i in range(len(node)):
		node[i].set_text(str(player.get_stats(i + 4)) + "\n")


# Sets elemental resistance info
# WARNING: DO NOT CHANGE ORDER
func set_resist_info(player):
	var node = $Columns/Resistances/Values.get_children()
	for i in range(len(node)):
		var type = node[i].get_name()
		node[i].set_text(str(player.get_resist(type)) + "\n")
