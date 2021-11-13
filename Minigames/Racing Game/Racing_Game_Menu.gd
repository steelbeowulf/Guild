extends Minigame_Menu

func _on_Controls_button_down():
	get_tree().change_scene("res://Minigames/Racing Game/Racing_Game_Controls.tscn")

func _on_Quit_button_down():
	get_tree().quit()

func _on_Start_button_down():
	get_tree().change_scene("res://Minigames/Racing Game/Racing_Game_Game.tscn")
