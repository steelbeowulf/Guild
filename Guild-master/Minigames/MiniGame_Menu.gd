extends Node
class_name Minigame_Menu

func _ready():
	# test
	AUDIO.initSound()
	AUDIO.play_bgm("MINIGAME_THEME")

func _on_Start_button_down():
	AUDIO.play_se("ENTER_MENU")

# show the ControlMenu's screen
func _on_Controls_button_down():
	AUDIO.play_se("ENTER_MENU")
	$ControlMenu.visible = true

func _on_Exit_button_down():
	AUDIO.play_se("EXIT_MENU")
	get_tree().quit()
	
# close the ControlMenu's screen
func _on_Close_button_down():
	AUDIO.play_se("ENTER_MENU")
	$ControlMenu.visible = false
