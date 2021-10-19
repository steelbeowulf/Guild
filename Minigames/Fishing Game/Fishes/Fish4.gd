extends Area2D

const r: float = 3000.0

onready var Timer = $Timer
var time: float
var initial_position = Vector2(0,0)
var direction: int = 0  # 1 inverts axis x and y 

signal fish_catched

func _ready():
	connect("fish_catched",get_parent(),"Fish_catched")

# curve circunference's involute
func _physics_process(delta):
	time = Timer.wait_time - Timer.time_left
	position[direction] = initial_position[direction] + r*(cos(time) + time*sin(time))*delta
	position[(direction + 1)%2] = initial_position[(direction + 1)%2] + r*(sin(time) - time*cos(time))*delta

func _on_Timer_timeout():
	queue_free()

func _on_Fish4_area_entered(area):
	emit_signal("fish_catched",4)
	queue_free()
