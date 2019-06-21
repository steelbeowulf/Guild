extends Node2D

var OFFSET_LANE = Vector2(140, 0)
var current_lane = 0
var initial_position
var my_turn = false
var bounds = [0,0,0,0,0]
export(bool) var Player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = self.get_global_position()
	if not Player:
		$Turn.set_color(Color(1, 0, 0))
		$ProgressBar.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_sprite(sprite):
	$Sprite.texture = load(sprite)

# Just hide for now
func die():
	$AnimationPlayer.play("Death")

func turn(keep=false):
	if keep:
		my_turn = true
	$Turn.show()

func end_turn(force=false):
	if not my_turn or force:
		$Turn.hide()

func change_lane(lane):
	var new_pos = initial_position
	if lane == 0: # back
		self.set_position(new_pos)
	elif lane == 1: # mid
		self.set_position(new_pos + OFFSET_LANE)
	elif lane == 2: # front
		self.set_position(new_pos + 2*OFFSET_LANE)

func update_bounds(bounds):
	self.bounds = bounds
	
func display_hate(value, id):
	if value == bounds[id]:
		$ProgressBar.tint_progress = Color(255, 0, 0)
	elif value > bounds[id] - 100:
		$ProgressBar.tint_progress = Color(255, 255, 0)
	else:
		$ProgressBar.tint_progress = Color(0, 40, 255)
	$ProgressBar.value = value
	$ProgressBar.max_value = bounds[id]
	$ProgressBar.show()
	
func hide_hate():
	$ProgressBar.hide()

func take_damage(value, type):
	if type == 0:
		if value < 0:
			value = abs(value)
			$Damage.self_modulate = Color(0, 255, 30)
		else:
			$Damage.self_modulate = Color(255, 255, 255)
	else:
		if value < 0:
			value = abs(value)
			$Damage.self_modulate = Color(0, 0, 255)
		else:
			$Damage.self_modulate = Color(125, 0, 160)
	$Damage.text = str(value)
	$Damage.show()
	$AnimationPlayer.play("Damage")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Death"):
		self.hide()
