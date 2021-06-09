extends Node2D

# test
func _ready():
	AUDIO.initSound()
	AUDIO.play_bgm("STRENGTH_TEST_THEME")

func _on_Start_button_down():
	get_tree().change_scene("res://Minigames/Strength Test/Strength_Test_Game.tscn")

func _on_Controls_button_down():
	AUDIO.play_se("ENTER_MENU")
	$ControlMenu.visible = true

func _on_Exit_button_down():
	AUDIO.play_se("EXIT_MENU")
	get_tree().quit()

func _on_Close_button_down():
	AUDIO.play_se("ENTER_MENU")
	$ControlMenu.visible = false
