extends KinematicBody2D

onready var Timer = $Timer
var time: float
var initial_position = Vector2(0,0)
var direction: int = 0   # 1 inverts axis x and y 

# curve synoid
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position[direction] = initial_position[direction] + 10000*time*delta
	position[(direction + 1)%2] = initial_position[(direction + 1)%2] + 10000*sin(time)*delta

func _on_Timer_timeout():
	queue_free()
