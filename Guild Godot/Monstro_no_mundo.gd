extends KinematicBody2D

export(int) var id
var chasing = null
const SPEED = 275
var velocity = Vector2(0,0)
const tolerance = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play(str(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = Vector2(0,0)
	if chasing == null:
		pass
	else:
		var my_pos = get_global_position()
		var leader_pos  = chasing.get_global_position()
		self.rotation = (my_pos - leader_pos).angle()
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


func _on_View_body_entered(body):
	if body.is_in_group("player"):
		chasing = body


func _on_View_body_exited(body):
	if body.is_in_group("player"):
		chasing = null

func _on_Battle_body_entered(body):
	if body.is_in_group("player"):
		var Enemies = self.get_parent().generate_enemies(id)
		BATTLE_INIT.begin_battle(Enemies, self.get_name())
		get_tree().change_scene("res://Battle/Battle.tscn")

