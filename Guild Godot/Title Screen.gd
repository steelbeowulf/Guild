extends Node

func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	get_tree().change_scene("res://Map.tscn")

func _on_Button2_pressed():
	get_tree().change_scene("res://Credits.tscn")
	
func _on_Button3_pressed():
	get_tree().quit()

