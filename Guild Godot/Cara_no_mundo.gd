extends KinematicBody2D

const SPEED = 250
var velocity = Vector2(0,0)
var id = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.animation = "walk_down"
	self.set_z_index(-id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(0,0)
	if id == 0:
		if Input.is_action_pressed("ui_up"):
			velocity.y = -SPEED
			$AnimatedSprite.play("walk_up")
		if Input.is_action_pressed("ui_down"):
			velocity.y = SPEED
			$AnimatedSprite.play("walk_down")
		if Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$AnimatedSprite.scale.x = -1
			$AnimatedSprite.play("walk_right")
		if Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.play("walk_right")
	else:
		var my_pos = get_global_position()
		var leader_pos  = BATTLE_INIT.get_leader_pos(id)
		if my_pos.y > leader_pos.y:
			velocity.y = -SPEED
			$AnimatedSprite.play("walk_up")
		if my_pos.y < leader_pos.y:
			velocity.y = SPEED
			$AnimatedSprite.play("walk_down")
		if my_pos.x > leader_pos.x:
			velocity.x = -SPEED
			$AnimatedSprite.scale.x = -1
			$AnimatedSprite.play("walk_right")
		if my_pos.x < leader_pos.x:
			velocity.x = SPEED
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.play("walk_right")

	if velocity == Vector2(0,0):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	
	move_and_slide(velocity)
