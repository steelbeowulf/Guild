extends Node

func _ready():
	$Button.grab_focus()


func _on_Button_pressed():
	get_tree().change_scene("res://Map.tscn")

func _on_Button2_pressed():
	#get_tree().set_pause(true)
	get_tree().change_scene("res://Credits.tscn")
	
func _on_Button3_pressed():
	get_tree().quit()

