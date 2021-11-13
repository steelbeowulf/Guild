extends Minigame_Menu

func _on_Start_button_down():
	get_tree().change_scene("res://Minigames/Fishing Game/FishingGame_Game.tscn")

func _on_Controls_button_down():
	get_tree().change_scene("res://Minigames/Fishing Game/FishingGame_ControlsMenu.tscn")

func _on_Quit_button_down():
	get_tree().quit()
