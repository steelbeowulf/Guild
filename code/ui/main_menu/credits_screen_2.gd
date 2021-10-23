extends Node


func _ready():
	AUDIO.stop_bgm()
	$Title.grab_focus()


func _on_Title_pressed():
	AUDIO.play_se("EXIT_MENU")
	get_tree().change_scene("res://code/ui/main_menu/title_screen.tscn")


func _on_Credits_pressed():
	AUDIO.play_se("ENTER_MENU")
	get_tree().change_scene("res://code/ui/main_menu/credits_screen.tscn")


func _on_Title_focus_entered():
	AUDIO.play_se("MOVE_MENU")


func _on_Credits_focus_entered():
	AUDIO.play_se("MOVE_MENU")
