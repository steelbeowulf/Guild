extends KinematicBody2D

const SPEED = 250
var velocity = Vector2(0,0)
var id = -1
var tolerance = 0.0
onready var stop = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "walk_down"
	self.set_z_index(-id)
	var margin = get_parent().get_parent().get_map_margin()
	$Camera2D.set_limit(MARGIN_BOTTOM, margin[0])
	$Camera2D.set_limit(MARGIN_LEFT, margin[1])
	$Camera2D.set_limit(MARGIN_TOP, margin[2])
	$Camera2D.set_limit(MARGIN_RIGHT, margin[3])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(0,0)
	if stop == []:
		if Input.is_action_pressed("ui_up"):
			velocity.y = -SPEED
			$AnimatedSprite.play("walk_up")
			$Head.rotation_degrees = 0
		if Input.is_action_pressed("ui_down"):
			velocity.y = SPEED
			$AnimatedSprite.play("walk_down")
			$Head.rotation_degrees = 180
		if Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$AnimatedSprite.scale.x = -1
			$AnimatedSprite.play("walk_right")
			$Head.rotation_degrees = 270
		if Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.play("walk_right")
			$Head.rotation_degrees = 90

	if velocity == Vector2(0,0):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	
	move_and_slide(velocity)

func _update(value):
	var pos = value[1]
	value = value[0]
	if value:
		self.queue_free()
	self.set_global_position(pos)

func dir():
	return str($Head.rotation_degrees)

func norm(vec):
	return sqrt(vec.x*vec.x + vec.y*vec.y)