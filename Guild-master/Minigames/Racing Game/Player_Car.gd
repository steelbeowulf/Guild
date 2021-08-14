extends KinematicBody2D

var velocity = Vector2(0,0)
var speed: float = 300.0
onready var Sprite = $Sprite

# for each delta the car will move
func _physics_process(delta):
	var mouse = get_global_mouse_position() - self.global_position
	velocity = mouse.normalized()
	velocity *= speed
	Sprite.rotate(mouse.angle() - Sprite.global_rotation)
	move_and_slide(velocity)

