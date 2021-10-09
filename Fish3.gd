extends KinematicBody2D

const r: float = 100.0

onready var Timer = $Timer
var time: float
var initial_position = Vector2(0,0)

# curve cycloid
func _physics_process(_delta):
	time = Timer.wait_time - Timer.time_left
	position = initial_position + r*Vector2(time - sin(time), 1 - cos(time))
	

func _on_Timer_timeout():
	queue_free()
