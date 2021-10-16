extends KinematicBody2D

const gama: float = -0.5
const omega: float = 10.0

onready var Timer = $Timer
var time: float
var initial_position = Vector2(300,300)
var direction: int = 1   # 0 when the graphic is f(x) = y, 1 when the graphic is g(y) = x

# damped harmonic moviment: subcritical regime
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position[direction] = initial_position[direction] + 10000*time*delta
	position[(direction + 1)%2] = initial_position[(direction + 1)%2] + 10000*exp(gama*time)*cos(omega*time)*delta

func _on_Timer_timeout():
	queue_free()