extends Node2D

signal arrow_vector 

onready var Bow_Position = $Bow_Position

func _ready():
	get_tree().paused = true

# the game starts
func _on_Start_Timer_timeout():
	get_tree().paused = false
	$GO.visible = true

func _unhandled_input(event):
	var arrow_direction = Vector2(0,0)
	var speed = 100.0
	if event is InputEventKey:
		#if event.pressed:
			# animation
		# when the player realeases the left mouse button the arrow will be shot by the bow
		if event.is_action_released("shot"):
			arrow_direction = ((get_global_mouse_position() - Bow_Position.position).normalized())*speed
			# this signal will be used in arrow script
			emit_signal("arrow_vector",arrow_direction)

func _on_Quit_button_down():
	get_tree().quit()
