extends KinematicBody2D

const r: float = 3000.0

onready var Timer = $Timer
var time: float
var initial_position = Vector2(500,500)
var direction: int = 0  # 1 inverts axis x and y 

# curve circunference's involute
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position[direction] = initial_position[direction] + r*(cos(time) + time*sin(time))*delta
	position[(direction + 1)%2] = initial_position[(direction + 1)%2] + r*(sin(time) - time*cos(time))*delta

func _on_Timer_timeout():
	queue_free()
