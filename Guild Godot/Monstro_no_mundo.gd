extends KinematicBody2D

enum MOVEMENT {idle, left_right, up_down, circle, random}
enum MODE {chasing, returning, moving}

export(int) var id
export(MOVEMENT) var movement = MOVEMENT.idle
export(float) var radius = 0.0
var mode = MODE.moving
const SPEED = 275
var velocity = Vector2(0,0)
var base_pos
var my_pos
var chasing = null
var prev_velocity = Vector2(0,0)
const tolerance = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	base_pos = self.get_global_position()
	$AnimatedSprite.play(str(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	prev_velocity = velocity
	velocity = Vector2(0,0)
	my_pos = self.get_global_position()
	match mode:
		MODE.moving:
			velocity = get_movement()
		MODE.returning:
			var leader_pos  = base_pos
			if norm(leader_pos - my_pos) < 1:
				mode = MODE.moving
			$View.rotation = (my_pos - leader_pos).angle()
			if my_pos.y - leader_pos.y > tolerance:
				velocity.y = -SPEED
			if my_pos.y - leader_pos.y < tolerance:
				velocity.y = SPEED
			if my_pos.x - leader_pos.x > tolerance:
				velocity.x = -SPEED
				$AnimatedSprite.scale.x = -1
			if my_pos.x - leader_pos.x < tolerance:
				velocity.x = SPEED
				$AnimatedSprite.scale.x = 1
		MODE.chasing:
			var leader_pos  = chasing.get_global_position()
			$View.rotation = (my_pos - leader_pos).angle()
			if my_pos.y - leader_pos.y > tolerance:
				velocity.y = -SPEED
			if my_pos.y - leader_pos.y < tolerance:
				velocity.y = SPEED
			if my_pos.x - leader_pos.x > tolerance:
				velocity.x = -SPEED
				$AnimatedSprite.scale.x = -1
			if my_pos.x - leader_pos.x < tolerance:
				velocity.x = SPEED
				$AnimatedSprite.scale.x = 1

	if velocity == Vector2(0,0):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
	else:
		$AnimatedSprite.play(str(id))
	
	move_and_slide(velocity)

func get_movement():
	var direction = 1
	match movement:
		MOVEMENT.idle:
			return Vector2(0,0)
		MOVEMENT.left_right:
			if prev_velocity.x >= 0:
				if my_pos.x > base_pos.x + radius:
					direction = -1
					self.scale.x = 1
			else:
				if my_pos.x > base_pos.x - radius:
					direction = -1
					self.scale.x = 1
			$AnimatedSprite.scale.x = -direction
			$View.rotation = (my_pos - base_pos - direction*Vector2(radius, 0)).angle()
			return Vector2(direction*SPEED, 0)
		MOVEMENT.up_down:
			if prev_velocity.y >= 0:
				if my_pos.y > base_pos.y + radius:
					direction = -1
			else:
				if my_pos.y > base_pos.y - radius:
					direction = -1
			$View.rotation = (my_pos - base_pos - direction*Vector2(0, radius)).angle()
			return Vector2(0, direction*SPEED)
		MOVEMENT.circle:
			return Vector2(0,0)
		MOVEMENT.random:
			return Vector2(0,0)

func _on_View_body_entered(body):
	if body.is_in_group("player"):
		chasing = body
		mode = MODE.chasing


func _on_View_body_exited(body):
	if body.is_in_group("player"):
		chasing = null
		mode = MODE.returning


func _on_Battle_body_entered(body):
	if body.is_in_group("player"):
		var Enemies = self.get_parent().generate_enemies(id)
		BATTLE_INIT.begin_battle(Enemies, self.get_name())
		get_tree().change_scene("res://Battle/Battle.tscn")

func norm(vec):
	return sqrt(vec.x*vec.x + vec.y*vec.y)
