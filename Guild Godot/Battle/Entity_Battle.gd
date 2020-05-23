extends Node2D

var OFFSET_LANE = Vector2(140, 0)
var current_lane = 0
var initial_position
var my_turn = false
var bounds = [0,0,0,0,0]
var data = null
var SHADER = preload("res://Assets/Shaders/outline.shader")
export(bool) var Player = false

var COLORS = {"RED": Color(1,0,0), "BLUE": Color(0,1,0),
"PURPLE": Color(1,0,1), "GRAY": Color(0.25, 0.25, 0.25), 
"PINK": Color(0.25,0,0), "YELLOW": Color(1,1,0)}

signal finish_anim

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = self.get_global_position()
	if not Player:
		$Turn.set_color(Color(1, 0, 0))

func set_aura(status):
	for anim in $Animations.get_children():
		anim.material.set_shader_param("outline_width", status[1])
		anim.material.set_shader_param("outline_color", COLORS[status[0]])

func remove_aura():
	for anim in $Animations.get_children():
		anim.material.set_shader_param("outline_width", 0)
		anim.material.set_shader_param("outline_color", "")

func set_spell(sprite, v, k):
	print("setting spell")
	print(v)
	print(k)
	var img = sprite['path']
	var vf = sprite['vframes']
	var hf = sprite['hframes']
	var sc = sprite['scale']
	var animation = Sprite.new()
	animation.texture = load(img)
	animation.set_name(k)
	animation.set_script(load('res://Battle/Spritesheet.gd'))
	animation.loop = v[0]
	animation.physical_frames = v[1]
	animation.vframes = vf
	animation.hframes = hf
	animation.scale = Vector2(sc[0], sc[1])
	animation.fps = 10
	#animation.speed = BATTLE_MANAGER.animation_speed
	animation.playing = false
	animation.hide()
	animation.connect('animation_finished', self, "_on_Spell_animation_finished")
	$Spells.add_child(animation)

func set_animations(sprite, animations, data_arg):
	self.data = data_arg
	var img = sprite['path']
	var vf = sprite['vframes']
	var hf = sprite['hframes']
	var sc = sprite['scale']
	
	for k in animations.keys():
		var v = animations[k]
		var animation = Sprite.new()
		animation.texture = load(img)
		var mat = ShaderMaterial.new()
		mat.set_shader(SHADER)
		animation.set_material(mat)
		animation.set_name(k)
		#print(k)
		animation.set_script(load('res://Battle/Spritesheet.gd'))
		animation.loop = v[0]
		animation.physical_frames = v[1]
		animation.vframes = vf
		animation.hframes = hf
		animation.scale = Vector2(sc[0], sc[1])
		animation.fps = 10
		#animation.speed = BATTLE_MANAGER.animation_speed
		animation.hide()
		animation.playing = false
		animation.connect('animation_finished', self, "_on_Sprite_animation_finished")
		$Animations.add_child(animation)

func play(name, options=[]):
	print("[ENTITY BATTLE] playing animation "+name)
	print(options)
	var node = $Animations
	if name == 'Damage':
		take_damage(options, 0)
		return
	if typeof(options) == TYPE_STRING and options == 'Skill':
		node = $Spells
	else:
		for c in $Animations.get_children():
			c.hide()
	print(name)
	print(node.get_name())
	node.get_node(name).show()
	node.get_node(name).play(true)

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
	pass
#	if value == bounds[id]:
#		$ProgressBar.tint_progress = Color(255, 0, 0)
#	elif value > bounds[id] - 100:
#		$ProgressBar.tint_progress = Color(255, 255, 0)
#	else:
#		$ProgressBar.tint_progress = Color(0, 40, 255)
#	$ProgressBar.value = value
#	$ProgressBar.max_value = bounds[id]
#	$ProgressBar.show()
	
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

func _on_Sprite_animation_finished(name):
	print("[ENTITY BATTLE] finished animation "+name)
	emit_signal("finish_anim", name)
	$Animations.get_node(name).hide()
	if name == "death":
		$Animations.get_node("dead").show()
		$Animations.get_node("dead").play(true)
	elif name == "dead":
		$Animations.get_node("dead").show()
		$Animations.get_node("dead").play(true)
	else:
		$Animations.get_node("idle").show()
		$Animations.get_node("idle").play(true)

func _on_Spell_animation_finished(name):
	print("[ENTITY BATTLE] finished spell animation "+name)
	emit_signal("finish_anim", name)
	$Spells.get_node(name).hide()
