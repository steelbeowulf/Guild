extends KinematicBody2D

const speed: float = 80.0
var initial_position = Vector2(0,0)

# curve y = k
func _physics_process(delta):
	position.x += initial_position.x + speed*delta
	

func _on_Timer_timeout():
	queue_free()
