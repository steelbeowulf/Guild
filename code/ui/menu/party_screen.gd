extends Control

const RESERVE_PATH = "res://data/game_data/Seeds/Reserve Players.json"

onready var player = null
onready var reserve_party = null
onready var reserve = []
onready var location = "OUTSIDE"
onready var player_id = null


func _ready():
	give_focus()
	var reserve_nodes = $Panel/HBoxContainer/Reserve.get_children()
	for i in range(len(reserve_nodes)):
		var node = reserve_nodes[i]
		node.connect("target_picked", self, "_on_Change_selected", [i])
		node.connect("target_selected", self, "_on_Change_hover", [i])
	var btns = $Panel/HBoxContainer/Options.get_children()
	for i in len(GLOBAL.players):
		btns[i + 1].connect("focus_entered", self, "_on_focus_entered")
		btns[i + 1].connect("pressed", self, "_on_Player_selected", [i])
		btns[i + 1].set_focus_mode(0)
		btns[i + 1].set_text(GLOBAL.players[i].get_name())
		btns[i + 1].show()
	get_node("Panel/HBoxContainer/Options/Player1").grab_focus()


func just_entered():
	print("[CHANGE] just entered ")
	location = "SUBMENU"


func show_reserve():
	reset_info()
	# Ponto inicial da lista
	var r_player = GLOBAL.reserve_PLAYERS
	for j in range(0, len(r_player)):
		var node = get_node("Panel/HBoxContainer/Reserve/ReserveSlot" + str(j + 1))
		node.set_text(str(r_player[j].get_name()))
		node.show()
		node.disabled = false


#Change the players in party to the reserve
func _on_Change_selected(id_reserve):
	AUDIO.play_se("ENTER_MENU")
	change_players(player_id, id_reserve)


func _on_Change_hover(_id: int):
	AUDIO.play_se("MOVE_MENU")


# Reset info panel
func reset_info():
	var btns = $Panel/HBoxContainer/Options.get_children()
	for i in len(GLOBAL.players):
		btns[i + 1].set_text(GLOBAL.players[i].get_name())


# TODO: Arrumar location (minuscula? maiuscula? idk)
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and player_id != null:
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and player_id == null:
		AUDIO.play_se("EXIT_MENU")
		location = "MENU"
		get_parent().get_parent().get_parent().return_menu()


func give_focus():
	$Panel/HBoxContainer/Options/Player1.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Player2.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Player3.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Player4.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Reserve.get_children():
		e.set_focus_mode(0)
		e.hide()
	get_node("Panel/HBoxContainer/Options/Player1").grab_focus()
	reset_info()


func enter():
	give_focus()
	get_node("Panel/HBoxContainer/Options/Player1").grab_focus()


# Trade player from the reserve to the active party
func change_players(id_player: int, id_reserve: int):
	AUDIO.play_se("ENTER_MENU")
	var loader = GLOBAL.get_root().get_parent().get_node("/root/LOADER")
	var a = GLOBAL.players[id_player]
	GLOBAL.players[id_player] = GLOBAL.reserve_PLAYERS[id_reserve]
	GLOBAL.reserve_PLAYERS[id_reserve] = a
	player_id = null
	show_reserve()


func _on_Back_pressed():
	AUDIO.play_se("EXIT_MENU")
	location = "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()


func _on_focus_entered():
	AUDIO.play_se("MOVE_MENU")


func _on_Player_selected(id: int):
	player_id = id
	location = "CHANGE"
	show_reserve()
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Reserve.get_children():
		e.set_focus_mode(2)
	get_node("Panel/HBoxContainer/Reserve/ReserveSlot1").grab_focus()
