extends KinematicBody2D

onready var Timer = $Timer
var time: float
var initial_position = Vector2(0,300)

# curve synoid
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position = initial_position + 10000*Vector2(time, sin(time))*delta
	

func _on_Timer_timeout():
	queue_free()
