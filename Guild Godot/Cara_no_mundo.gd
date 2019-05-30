extends KinematicBody2D

const SPEED = 250
var velocity = Vector2(0,0)
var leader_vel = Vector2(0,0)
var id = -1

func get_back():
	return $Back.get_global_position()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "walk_down"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(0,0)
	leader_vel = Vector2(0,0)
	if id == 0:
		if Input.is_action_pressed("ui_up"):
			$Back.rotation_degrees = 0
			velocity.y = -SPEED
			leader_vel.y = -SPEED
			$AnimatedSprite.play("walk_up")
		if Input.is_action_pressed("ui_down"):
			$Back.rotation_degrees = 180
			velocity.y = SPEED
			leader_vel.y = SPEED
			$AnimatedSprite.play("walk_down")
		if Input.is_action_pressed("ui_left"):
			$Back.rotation_degrees = 270
			velocity.x = -SPEED
			leader_vel.x = -SPEED
			$AnimatedSprite.scale.x = -1
			$AnimatedSprite.play("walk_right")
		if Input.is_action_pressed("ui_right"):
			$Back.rotation_degrees = 90
			velocity.x = SPEED
			leader_vel.x = SPEED
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.play("walk_right")
	else:
		var leader = BATTLE_INIT.get_back_pos(id)
		var leader_pos = leader[0]
		leader_vel = leader[1]
		print(leader_pos)
		var my_pos = get_global_position()
		if my_pos.y > leader_pos.y:
			$Back.rotation_degrees = 0
			velocity.y = -SPEED
			$AnimatedSprite.play("walk_up")
		if my_pos.y < leader_pos.y:
			velocity.y = SPEED
			$AnimatedSprite.play("walk_down")
			$Back.rotation_degrees = 180
		if my_pos.x > leader_pos.x:
			$Back.rotation_degrees = 270
			velocity.x = -SPEED
			$AnimatedSprite.scale.x = -1
			$AnimatedSprite.play("walk_right")
		if my_pos.x < leader_pos.x:
			$Back.rotation_degrees = 90
			velocity.x = SPEED
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.play("walk_right")

	if velocity == Vector2(0,0) or leader_vel == Vector2(0,0):
		velocity = Vector2(0,0)
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	
	move_and_slide(velocity)
