extends KinematicBody2D

# Movement speed
const SPEED = 13500
var velocity = Vector2(0,0)

# List of objects stopping player from moving
onready var stop = []

# Initializes player on map - sets position and camera
func _initialize():
	if GLOBAL.POSITION:
		position = GLOBAL.POSITION
	$AnimatedSprite.animation = "walk_down"
	self.set_z_index(1)
	var margin = get_parent().get_parent().get_map_margin()
	$Camera2D.set_limit(MARGIN_BOTTOM, margin[0])
	$Camera2D.set_limit(MARGIN_LEFT, margin[1])
	$Camera2D.set_limit(MARGIN_TOP, margin[2])
	$Camera2D.set_limit(MARGIN_RIGHT, margin[3])
	print("[PLAYER POSITION] "+str(position))


# Deals with input and moves player
func _physics_process(delta):
	velocity = Vector2(0,0)
	if stop == []:
		if Input.is_action_pressed("ui_up"):
			velocity.y = -SPEED
			$AnimatedSprite.play("walk_up")
			$Head.rotation_degrees = 0
		elif Input.is_action_pressed("ui_down"):
			velocity.y = SPEED
			$AnimatedSprite.play("walk_down")
			$Head.rotation_degrees = 180
		if Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$AnimatedSprite.scale.x = -1
			if velocity.y == 0:
				$AnimatedSprite.play("walk_right")
			$Head.rotation_degrees = 270
		elif Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$AnimatedSprite.scale.x = 1
			if velocity.y == 0:
				$AnimatedSprite.play("walk_right")
			$Head.rotation_degrees = 90

	if velocity == Vector2(0,0):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()

	move_and_slide(velocity*delta)


# Returns direction player is facing
func dir():
	return str($Head.rotation_degrees)
