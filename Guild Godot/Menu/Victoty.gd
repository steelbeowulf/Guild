extends Node

func _ready():
	$Title.grab_focus()

func _on_Button_pressed():
	get_tree().change_scene("res://Menu/Title Screen.tscn")
