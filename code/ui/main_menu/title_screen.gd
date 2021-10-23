extends Node

signal slot_chosen


func _ready():
	AUDIO.init_sound()
	$New.grab_focus()
	$New.connect("focus_entered", self, "_on_Focus_entered")
	$Load.connect("focus_entered", self, "_on_Focus_entered")
	$Credits.connect("focus_entered", self, "_on_Focus_entered")
	$Exit.connect("focus_entered", self, "_on_Focus_entered")
	var tmp = 0
	for c in get_node("Load_Screen/Save Slots").get_children():
		c.connect("button_down", self, "_on_Slot_chosen", [tmp])
		c.connect("focus_entered", self, "_on_Focus_entered")
		tmp += 1


func _on_New_pressed():
	AUDIO.play_se("ENTER_MENU")
	GLOBAL.load_game(-1)
	#get_tree().change_scene("res://code/root.tscn")
	get_tree().change_scene("res://code/ui/main_menu/loading_screen.tscn")


func _on_Load_pressed():
	AUDIO.play_se("ENTER_MENU")
	$"Load_Screen/Save Slots".enable_focus(false)
	$Load_Screen.show()


func _on_Slot_chosen(slot):
	AUDIO.play_se("ENTER_MENU")
	GLOBAL.load_game(slot)
	get_tree().change_scene("res://code/ui/main_menu/loading_screen.tscn")


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		AUDIO.play_se("EXIT_MENU")
		$Load_Screen.hide()
		$"Load_Screen/Save Slots".remove_focus()
		$New.grab_focus()


func _on_Exit_pressed():
	AUDIO.play_se("EXIT_MENU")
	get_tree().quit()


func _on_Credits_pressed():
	AUDIO.play_se("ENTER_MENU")
	get_tree().change_scene("res://code/ui/main_menu/credits_screen.tscn")


func _on_Focus_entered():
	AUDIO.play_se("MOVE_MENU")
