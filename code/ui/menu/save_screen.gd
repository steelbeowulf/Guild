extends Control

onready var state = 0
onready var chosen_slot = -1
onready var loader = get_node("/root/LOADER")
onready var location = "OUTSIDE"

var slots = null

signal slot_chosen

# Called when the node enters the scene tree for the first time.
func _ready():
	slots = get_node("All/Left/Save Slots")
	remove_focus()
	var tmp = 0
	for c in slots.get_children():
		c.connect("button_down", self, "_on_Slot_chosen", [tmp])
		c.connect("focus_entered", self, "_on_Focus_Entered")
		tmp += 1
	for btn in $All/Right/Options_Panel.get_children():
		btn.connect("focus_entered", self, "_on_Focus_Entered")

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and location == "SAVE":
		AUDIO.play_se("EXIT_MENU")
		location = "OUTSIDE"
		state = 0
		remove_focus()
	elif event.is_action_pressed("ui_cancel") and location == "LOAD":
		AUDIO.play_se("EXIT_MENU")
		location = "OUTSIDE"
		state = 0
		remove_focus()
	elif event.is_action_pressed("ui_cancel") and location == "OUTSIDE":
		AUDIO.play_se("EXIT_MENU")
		get_parent().get_parent().get_parent().return_menu()

func _on_Slot_chosen(binds):
	AUDIO.play_se("ENTER_MENU")
	chosen_slot = binds
	if state == 1:
		$SaveDialog.popup()
	elif state == 2:
		$LoadDialog.popup()

func _on_Save_pressed():
	AUDIO.play_se("ENTER_MENU")
	location = "SAVE"
	state = 1
	slots.enable_focus(true)


func _on_Load_pressed():
	AUDIO.play_se("ENTER_MENU")
	location = "LOAD"
	state = 2
	slots.enable_focus(false)


func _on_Quit_pressed():
	AUDIO.play_se("ENTER_MENU")
	$QuitDialog.popup()


func _on_QuitDialog_confirmed():
	AUDIO.play_se("EXIT_MENU")
	get_tree().quit()

func remove_focus():
	slots.remove_focus()
	get_node("All/Right/Options_Panel/Save").grab_focus()
	get_node("All/Right/Options_Panel/Save").pressed = false
	get_node("All/Right/Options_Panel/Load").pressed = false


func _on_SaveDialog_confirmed():
	AUDIO.play_se("ENTER_MENU")
	location = "OUTSIDE"
	SAVE.save(chosen_slot)
	slots.load_saves(LOADER.load_save_info())


func _on_LoadDialog_confirmed():
	location = "OUTSIDE"
	AUDIO.play_se("ENTER_MENU")
	GLOBAL.INVENTORY = loader.load_inventory(chosen_slot)
	GLOBAL.PLAYERS = loader.load_players(chosen_slot)
	LOCAL.reload_state()
	GLOBAL.load_game(chosen_slot)
	GLOBAL.get_root().close_menu()
	GLOBAL.get_root().transition(LOCAL.MAP, true)
	get_tree().change_scene("res://code/root.tscn")

func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")