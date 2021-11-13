extends Minigame_Menu

func _on_Start_button_down():
	get_tree().change_scene("res://Minigames/Strength Test/Strength_Test_Game.tscn")

func _on_Controls_button_down():
	get_tree().change_scene("res://Minigames/Strength Test/Strength_Test_Controls.tscn")

func _on_Quit_button_down():
	get_tree().quit()
