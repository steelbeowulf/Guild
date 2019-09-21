extends Node2D

var OFFSET_LANE = Vector2(140, 0)
var current_lane = 0
var initial_position
var my_turn = false
var bounds = [0,0,0,0,0]
export(bool) var Player = false
var parent

signal finish_anim

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = self.get_global_position()
	if not Player:
		$Turn.set_color(Color(1, 0, 0))
		$ProgressBar.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_animations(sprite, animations):
	$Spritesheet.texture = load(sprite)
	for k in animations.keys():
		var v = animations[k]
		print("adicionando animacao "+str(k))
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, "Spritesheet:frame")
		animation.set_loop(v[0])
		print("setting loop as "+str(v[0]))
		var time = 0.0
		v.pop_front()
		for frame in v:
			print("adicionando frame "+str(frame))
			animation.track_insert_key(track_index, time, frame)
			time += 0.2
		animation.set_length(time)
		$AnimationPlayer.add_animation(k , animation)
	$AnimationPlayer.play("idle")
	self.parent.connect("anim_finished", self, "_anim_finished")

# Just hide for now
func die():
	$AnimationPlayer.play("Death")

func revive():
	$AnimationPlayer.play_backwards("Death")

func turn(keep=false):
	if keep:
		my_turn = true
	$Turn.show()

func end_turn(force=false):
	if not my_turn or force:
		my_turn = false
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
	var bad_heal = (str(value) == "-0")
	if type == 0:
		if value < 0 or bad_heal:
			value = abs(value)
			$Damage.self_modulate = Color(0, 255, 30)
		else:
			$Damage.self_modulate = Color(255, 255, 255)
	else:
		if value < 0 or bad_heal:
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
	elif (anim_name == "Damage"):
		emit_signal("finish_anim")
