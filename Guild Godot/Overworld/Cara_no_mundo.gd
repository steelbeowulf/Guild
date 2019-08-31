extends KinematicBody2D

const SPEED = 250
var velocity = Vector2(0,0)
var id = -1
var tolerance = 0.0
onready var stop = []

var speed = 256 # big number because it's multiplied by delta
var tile_size = 32 # size in pixels of tiles on the grid
var last_position = Vector2() # last idle position
var target_position = Vector2() # desired position to move towards
var movedir = Vector2() # move direction

onready var ray = $RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if GLOBAL.POSITION:
		position = GLOBAL.POSITION
	else:
		position = Vector2(816, 368)
	$AnimatedSprite.animation = "walk_down"
	self.set_z_index(-id)
	var margin = get_parent().get_parent().get_map_margin()
	$Camera2D.set_limit(MARGIN_BOTTOM, margin[0])
	$Camera2D.set_limit(MARGIN_LEFT, margin[1])
	$Camera2D.set_limit(MARGIN_TOP, margin[2])
	$Camera2D.set_limit(MARGIN_RIGHT, margin[3])
	#position = position.snapped(Vector2(tile_size, tile_size)) # make sure player is snapped to grid
	last_position = position
	target_position = position

func get_movedir():
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")
	
	movedir.x = -int(LEFT) + int(RIGHT) # if pressing both directions this will return 0
	movedir.y = -int(UP) + int(DOWN)
		
	if movedir.x != 0 && movedir.y != 0: # prevent diagonals
		movedir = Vector2.ZERO
		
	if movedir != Vector2.ZERO:
		ray.cast_to = movedir * tile_size / 4
	
	if movedir.y < 0:
		$AnimatedSprite.play("walk_up")
		$Head.rotation_degrees = 0
	elif movedir.y > 0:
		$AnimatedSprite.play("walk_down")
		$Head.rotation_degrees = 180
	elif movedir.x < 0:
		$AnimatedSprite.scale.x = -1
		$AnimatedSprite.play("walk_right")
		$Head.rotation_degrees = 270
	elif movedir.x > 0:
		$AnimatedSprite.scale.x = 1
		$AnimatedSprite.play("walk_right")
		$Head.rotation_degrees = 90

func _physics_process(delta):
    	# MOVEMENT
    	if ray.is_colliding():
    		print("AAAAAA!")
    		position = last_position
    		target_position = last_position
    	else:
    		position += speed * movedir * delta
    		
    		if position.distance_to(last_position) >= tile_size: # if we've moved further than one space
    			position = target_position # snap the player to the intended position
    	
    	# IDLE
    	if position == target_position:
    		get_movedir()
    		if movedir == Vector2.ZERO:
    			$AnimatedSprite.stop()
    		last_position = position # record the player's current idle position
    		target_position += movedir * tile_size # if key is pressed, get new target (also shifts to moving state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
#	velocity = Vector2(0,0)
#	if stop == []:
#		if Input.is_action_pressed("ui_up"):
#			velocity.y = -SPEED
#			$AnimatedSprite.play("walk_up")
#			$Head.rotation_degrees = 0
#		if Input.is_action_pressed("ui_down"):
#			velocity.y = SPEED
#			$AnimatedSprite.play("walk_down")
#			$Head.rotation_degrees = 180
#		if Input.is_action_pressed("ui_left"):
#			velocity.x = -SPEED
#			$AnimatedSprite.scale.x = -1
#			$AnimatedSprite.play("walk_right")
#			$Head.rotation_degrees = 270
#		if Input.is_action_pressed("ui_right"):
#			velocity.x = SPEED
#			$AnimatedSprite.scale.x = 1
#			$AnimatedSprite.play("walk_right")
#			$Head.rotation_degrees = 90
#
#	if velocity == Vector2(0,0):
#		$AnimatedSprite.frame = 0
#		$AnimatedSprite.stop()
#
#	move_and_slide(velocity)

func _update(value):
	var pos = value[1]
	value = value[0]
	if value:
		self.queue_free()
	self.position = pos

func dir():
	return str($Head.rotation_degrees)

func norm(vec):
	return sqrt(vec.x*vec.x + vec.y*vec.y)