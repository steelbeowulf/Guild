extends Control

onready var state = 0
onready var chosen_slot = -1
onready var loader = get_node("/root/LOADER")

var slots = null

signal slot_chosen

# Called when the node enters the scene tree for the first time.
func _ready():
	slots = get_node("Panel/All/Left/Save Slots")
	remove_focus()
	var tmp = 0
	for c in slots.get_children():
		c.connect("button_down", self, "_on_Slot_chosen", [tmp])
		tmp += 1

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		state = 0
		remove_focus()

func _on_Slot_chosen(binds):
	chosen_slot = binds
	if state == 1:
		$SaveDialog.popup()
	elif state == 2:
		$LoadDialog.popup()

func _on_Save_pressed():
	state = 1
	slots.enable_focus(true)


func _on_Load_pressed():
	state = 2
	slots.enable_focus(false)


func _on_Quit_pressed():
	$QuitDialog.popup()


func _on_QuitDialog_confirmed():
	get_tree().quit()

func remove_focus():
	slots.remove_focus()
	get_node("Panel/All/Right/Options_Panel/Save").grab_focus()
	get_node("Panel/All/Right/Options_Panel/Save").pressed = false
	get_node("Panel/All/Right/Options_Panel/Load").pressed = false


func _on_SaveDialog_confirmed():
	GLOBAL.save(chosen_slot)
	slots.load_saves(LOADER.load_save_info())


func _on_LoadDialog_confirmed():
	GLOBAL.INVENTORY = loader.load_inventory(chosen_slot)
	GLOBAL.ALL_PLAYERS = loader.load_players(chosen_slot)
	GLOBAL.reload_state()
	GLOBAL.load_game(chosen_slot)
	GLOBAL.get_root().close_menu()
	GLOBAL.get_root().transition(GLOBAL.MAP, true)
	get_tree().change_scene("res://Root.tscn")
