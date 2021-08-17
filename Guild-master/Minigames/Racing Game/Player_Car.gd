extends KinematicBody2D

var velocity = Vector2(0,0)
var speed: float = 300.0
var slip_rotation: float = 0
onready var Sprite = $Sprite

# for each delta the car will move
func _physics_process(delta):
	var mouse = get_global_mouse_position() - self.global_position
	#see the func car_slipped() in Racing_Game_Game.gd
	mouse = mouse.rotated(slip_rotation)
	# if < 17.5 the cursor is very next to the car, then the sprite will shake
	if mouse.length() > 17.5:
		velocity = mouse.normalized()*speed
		Sprite.rotate(mouse.angle() - Sprite.global_rotation)
	else:
		velocity = Vector2(0,0)
		Sprite.rotate(0)
	move_and_slide(velocity)
