extends Node

func _ready():
	AUDIO.stop_bgm()
	$Title.grab_focus()

func _on_Button_pressed():
	AUDIO.play_se("EXIT_MENU")
	get_tree().change_scene("res://Menu/Title Screen.tscn")


func _on_More_Credits_pressed():
	AUDIO.play_se("ENTER_MENU")
	get_tree().change_scene("res://Menu/Credits2.tscn")


func _on_Title_focus_entered():
	AUDIO.play_se("MOVE_MENU")


func _on_More_Credits_focus_entered():
	AUDIO.play_se("MOVE_MENU")
