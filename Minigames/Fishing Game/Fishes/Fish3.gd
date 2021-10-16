extends KinematicBody2D

const r: float = 5000.0

onready var Timer = $Timer
var time: float
var initial_position = Vector2(700,700)
var direction: int = 0  # 1 inverts axis x and y 

# curve cycloid
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position[direction] = initial_position[direction] + r*(time - sin(time))*delta
	position[(direction + 1)%2] = initial_position[(direction + 1)%2] + r*(1 - cos(time))*delta
	

func _on_Timer_timeout():
	queue_free()
