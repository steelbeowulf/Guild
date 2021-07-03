extends KinematicBody2D

const aceleration: float = 50.0
var velocity = Vector2(0,0)
#max value for velocity.x and velocity.y
var max_speed = 400.0
onready var Sprite = $Sprite

# for each delta the car will move
func _physics_process(delta):
	move_and_slide(velocity)
	
# change the car's velocity
func _unhandled_key_input(event):
	if event is InputEvent:
		if event.is_action_pressed("Move_Up"):
			velocity.y -= aceleration
			velocity.y = min(velocity.y,max_speed)
		if event.is_action_pressed("Move_Down"):
			velocity.y += aceleration
			velocity.y = min(velocity.y,max_speed)
		if event.is_action_pressed("Move_Left"):
			velocity.x -= aceleration
			velocity.x = min(velocity.x,max_speed)
		if event.is_action_pressed("Move_Right"):
			velocity.x += aceleration
			velocity.x = min(velocity.x,max_speed)
		Sprite.rotation = velocity.angle()*get_physics_process_delta_time()