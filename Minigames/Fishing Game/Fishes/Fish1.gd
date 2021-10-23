extends Area2D

const speed: float = 100.0
var initial_position = Vector2(0,0)
var direction: int = 0   # 1 inverts axis x and y 

signal fish_catched

func _ready():
	position = initial_position
	connect("fish_catched",get_parent(),"Fish_catched")

# curve y = k
func _physics_process(delta):
	position[direction] += speed*delta
	

func _on_Timer_timeout():
	queue_free()

func _on_Fish1_area_entered(area):
	emit_signal("fish_catched",1)
	queue_free()
