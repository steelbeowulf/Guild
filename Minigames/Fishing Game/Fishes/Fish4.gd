extends KinematicBody2D

const r: float = 40.0

onready var Timer = $Timer
var time: float
var initial_position = Vector2(500,500)

# curve circunference's involute
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position = initial_position + r*Vector2(cos(time) + time*sin(time),sin(time) - time*cos(time))

func _on_Timer_timeout():
	queue_free()
