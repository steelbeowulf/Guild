extends KinematicBody2D

const SPEED = 250
var velocity = Vector2(0,0)
var id = -1
var tolerance = 0.0
var stop = false

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
		if not stop or abs(norm(my_pos - leader_pos)) > 12*id:
			if my_pos.y - leader_pos.y > tolerance:
				self.set_z_index(id)
				velocity.y = -SPEED
				$AnimatedSprite.play("walk_up")
			if my_pos.y - leader_pos.y < tolerance:
				self.set_z_index(-id)
				velocity.y = SPEED
				$AnimatedSprite.play("walk_down")
			if my_pos.x - leader_pos.x > tolerance:
				#print("-SPEED")
				velocity.x = -SPEED
				$AnimatedSprite.scale.x = -1
				$AnimatedSprite.play("walk_right")
			if my_pos.x - leader_pos.x < tolerance:
				#print("SPEED")
				velocity.x = SPEED
				$AnimatedSprite.scale.x = 1
				$AnimatedSprite.play("walk_right")

	if velocity == Vector2(0,0):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	
	move_and_slide(velocity)

func norm(vec):
	return sqrt(vec.x*vec.x + vec.y*vec.y)

func _on_In_body_entered(body):
	if body.is_in_group("player") and body != self:
		body.stop = true


func _on_In_body_exited(body):
	if body.is_in_group("player") and body != self:
		body.stop = false
