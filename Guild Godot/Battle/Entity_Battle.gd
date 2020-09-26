extends Button

signal target_picked

func _on_P0_pressed():
	emit_signal("target_picked", [get_id()])


func _on_P0_focus_entered():
	$Sprite.show()
	


func _on_P0_focus_exited():
	$Sprite.hide()


func _on_Activate_Targets():
	print("ACTIVATING TARGETS")
	self.disabled = false
	self.set_focus_mode(2)
	self.grab_focus()

func _on_Deactivate_Targets():
	print("DEACTIVATING TARGETS")
	self.disabled = true
	self.set_focus_mode(0)


var OFFSET_LANE = Vector2(140, 0)
var current_lane = 0
var initial_position
var my_turn = false
var bounds = [0,0,0,0,0]
var data = null
var dead = false
var SHADER = preload("res://Assets/Shaders/outline.shader")
export(bool) var Player = false

var COLORS = {"RED": Color(1,0,0), "BLUE": Color(0,1,0),
"PURPLE": Color(1,0,1), "GRAY": Color(0.25, 0.25, 0.25), 
"PINK": Color(0.25,0,0), "YELLOW": Color(1,1,0)}

signal finish_anim

func get_id():
	if Player:
		return -(int(get_name()[1])+1)
	else:
		return int(get_name()[1])

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

func set_turn(visible: bool):
	$Turn.visibility = visible

func set_selected(visible: bool):
	$Target.visibility = visible

func revive():
	print("REVIVING")
	$Animations.get_node("dead").stop()
	$Animations.get_node("dead").hide()
	$Animations.get_node("idle").show()
	$Animations.get_node("idle").play()

func set_spell(sprite, v, k):
	print("[ENTITY BATTLE] Setting Spell "+str(k))
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
	animation.z_index = 20
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
	print("Options="+str(options))
	var node = $Animations
	if name == 'Damage':
		take_damage(options, 0)
		return
	if typeof(options) == TYPE_STRING and options == 'Skill':
		node = $Spells
	else:
		for c in $Animations.get_children():
			c.hide()
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
	
func take_damage(value, type):
	print("[ENTITY BATTLE] Taking damage, value="+str(value)+", type="+str(type))
	if typeof(value) == TYPE_ARRAY:
		for val in value:
			type = val[1]
			val = val[0]
			var bad_heal = (str(val) == "-0")
			$Damage.text = str(val)
			if type == 0:
				if val < 0 or bad_heal:
					val = abs(val)
					$Damage.text = "+"+str(val)
					$Damage.self_modulate = Color(0, 255, 30)
				else:
					$Damage.self_modulate = Color(255, 255, 255)
			else:
				if val < 0 or bad_heal:
					val = abs(val)
					$Damage.text = "+"+str(val)
					$Damage.self_modulate = Color(0, 0, 255)
				else:
					$Damage.self_modulate = Color(125, 0, 160)
	else:
		var bad_heal = (str(value) == "-0")
		$Damage.text = str(value)
		if type == 0:
			if value < 0 or bad_heal:
				value = abs(value)
				$Damage.text = "+"+str(value)
				$Damage.self_modulate = Color(0, 255, 30)
			else:
				$Damage.self_modulate = Color(255, 255, 255)
		else:
			if value < 0 or bad_heal:
				value = abs(value)
				$Damage.text = "+"+str(value)
				$Damage.self_modulate = Color(0, 0, 255)
			else:
				$Damage.self_modulate = Color(125, 0, 160)
	
	$Damage.show()
	$AnimationPlayer.play("Damage")

func _on_Sprite_animation_finished(name):
	print("[ENTITY BATTLE] finished animation "+name)
	emit_signal("finish_anim", name)
	$Animations.get_node(name).hide()
	if name == "death":
		dead = true
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
	$Spells.get_node(name).playing = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "Damage"):
		$Damage.hide()


