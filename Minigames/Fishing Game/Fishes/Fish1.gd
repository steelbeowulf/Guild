extends KinematicBody2D

const speed: float = 80.0
var initial_position = Vector2(0,0)
var direction: int = 0   # 1 inverts axis x and y 

func _ready():
	position = initial_position

# curve y = k
func _physics_process(delta):
	position[direction] += speed*delta
	

func _on_Timer_timeout():
	queue_free()
