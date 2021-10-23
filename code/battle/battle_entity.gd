# Button representing a target in battle
extends Button

signal target_picked
signal finish_anim

const SPRITE_SCRIPT = preload("res://code/classes/util/spritesheet.gd")
const OFFSET_LANE = Vector2(140, 0)

# Aura related variables
const SHADER = preload("res://assets/others/shaders/outline.shader")
const COLORS = {
	"RED": Color(1, 0, 0),
	"BLUE": Color(0, 1, 0),
	"PURPLE": Color(1, 0, 1),
	"GRAY": Color(0.25, 0.25, 0.25),
	"PINK": Color(0.25, 0, 0),
	"YELLOW": Color(1, 1, 0)
}

export(bool) var is_player = false

# Position related variables
onready var current_lane = 0
onready var initial_position = Vector2(0, 0)

# State related variables
onready var my_turn = false
onready var bounds = [0, 0, 0, 0, 0]
onready var data: Entity = null
onready var dead = false


# Sets initial position and turn indicator color
func _ready():
	initial_position = self.get_global_position()
	if not is_player:
		$Turn.set_color(Color(1, 0, 0))


############## Animations


# Callback for when a sprite animation finishes
func _on_Sprite_animation_finished(animation_name: String):
	emit_signal("finish_anim", animation_name)
	$Animations.get_node(animation_name).hide()
	if animation_name == "death":
		dead = true
		$Animations.get_node("idle").hide()
		$Animations.get_node("dead").show()
		$Animations.get_node("dead").play(true)
	elif animation_name == "dead":
		$Animations.get_node("dead").show()
		$Animations.get_node("dead").play(true)
	elif dead:
		$Animations.get_node("idle").hide()
		$Animations.get_node("dead").show()
		$Animations.get_node("dead").play(true)
	else:
		$Animations.get_node("idle").show()
		$Animations.get_node("idle").play(true)


# Callback for when a spell animation finishes
func _on_Spell_animation_finished(animation_name: String):
	emit_signal("finish_anim", animation_name)
	$Spells.get_node(animation_name).hide()
	$Spells.get_node(animation_name).playing = false


# Setup spell animations for this entity
# Sprite parameter has a path, frames and scale option
# Animation_data has [loop, frame] as value
func set_spell(sprite: Dictionary, animation_data: Array, animation_name: String):
	print("[ENTITY BATTLE] Setting Spell " + str(animation_name))
	var scale = sprite["scale"]
	var animation = Sprite.new()
	animation.texture = load(sprite["path"])
	animation.set_name(animation_name)
	animation.set_script(SPRITE_SCRIPT)
	animation.loop = animation_data[0]
	animation.physical_frames = animation_data[1]
	animation.vframes = sprite["vframes"]
	animation.hframes = sprite["hframes"]
	animation.scale = Vector2(scale[0], scale[1])
	animation.fps = 10
	# TODO: Make this customizable (issue #50)
	#animation.speed = BATTLE_MANAGER.animation_speed
	animation.playing = false
	animation.hide()
	animation.connect("animation_finished", self, "_on_Spell_animation_finished")
	animation.z_index = 20
	$Spells.add_child(animation)


# Setup animations for this entity
# Sprite parameter has a path, frames and scale option
# Animations is a dictionary of animation_names as key and [loop, frame] as value
# Data_arg is a reference to the entity this node represents
func set_animations(sprite: Dictionary, animations: Dictionary, data_arg: Entity):
	self.data = data_arg
	var scale = sprite["scale"]

	for k in animations.keys():
		var v = animations[k]
		var animation = Sprite.new()
		animation.texture = load(sprite["path"])
		var mat = ShaderMaterial.new()
		mat.set_shader(SHADER)
		animation.set_material(mat)
		animation.set_name(k)
		animation.set_script(SPRITE_SCRIPT)
		animation.loop = v[0]
		animation.physical_frames = v[1]
		animation.vframes = sprite["vframes"]
		animation.hframes = sprite["hframes"]
		animation.scale = Vector2(scale[0], scale[1])
		animation.fps = 10
		# TODO: Make this customizable (issue #50)
		#animation.speed = BATTLE_MANAGER.animation_speed
		animation.hide()
		animation.playing = false
		animation.connect("animation_finished", self, "_on_Sprite_animation_finished")
		$Animations.add_child(animation)


# Plays an animation from the current sprite and/or other animations
# such as the damage/critical/miss indicators
# Called by the animation_manager on the end of a turn
func play(animation_name: String, options = []):
	print("[ENTITY BATTLE] playing animation " + animation_name)
	var node = $Animations
	if animation_name == "end_turn":
		set_turn(false)
		emit_signal("finish_anim", "end_turn")
		return
	elif animation_name == "Entrance":
		enter_scene()
		return
	elif animation_name == "Damage":
		take_damage(options, 0)
		emit_signal("finish_anim", "Damage")
		return
	elif animation_name == "Critical":
		take_damage(options, 1)
		emit_signal("finish_anim", "Critical")
		return
	elif animation_name == "Miss":
		take_damage(options, -1)
		emit_signal("finish_anim", "Damage")
		return
	elif animation_name == "Death":
		dead = true
	if typeof(options) == TYPE_STRING and options == "Skill":
		node = $Spells
	else:
		for c in $Animations.get_children():
			c.hide()
	node.get_node(animation_name).show()
	node.get_node(animation_name).play(true)


############## Targetting


# Makes this entity targetable for current action
# is_ress flag is true when action is a ressurection spell,
# thus making a dead player targetable for a ressurection spell
func _on_Targets_activated(is_ress: bool):
	if (not dead and not is_ress) or (dead and self.data.tipo == "is_player" and is_ress):
		self.disabled = false
		self.set_focus_mode(2)
		self.grab_focus()


# Makes this entity not targetable for current action
func _on_Targets_deactivated():
	self.disabled = true
	self.set_focus_mode(0)


# Emit target_picked signal with target_id
func _on_Entity_pressed():
	emit_signal("target_picked", [get_id()])


# Show target picker
func on_entity_focus_entered():
	$Picker.show()


# Hide target picker
func on_entity_focus_exited():
	$Picker.hide()


############## Getters/Setters


# Return position on Enemies/Players array from Battle state
func get_id():
	if is_player:
		return -(int(get_name()[1]) + 1)
	else:
		return int(get_name()[1])


# TODO: Make status class
# Sets this sprite's outline color
# status_effect = [outline_width: float, outline_color: String]
func set_aura(status_effect: Array):
	for anim in $Animations.get_children():
		anim.material.set_shader_param("outline_width", status_effect[1])
		anim.material.set_shader_param("outline_color", COLORS[status_effect[0]])


# Remove this sprite's outline
func remove_aura():
	for anim in $Animations.get_children():
		anim.material.set_shader_param("outline_width", 0)
		anim.material.set_shader_param("outline_color", "")


# Show/hide turn indicator
func set_turn(visible: bool):
	$Turn.visible = visible


# Change this entity current lane
# And moves accordingly
func change_lane(lane: int):
	var new_pos = initial_position
	if lane == 0:  # Back
		self.set_position(new_pos)
	elif lane == 1:  # Mid
		self.set_position(new_pos + OFFSET_LANE)
	elif lane == 2:  # Front
		self.set_position(new_pos + 2 * OFFSET_LANE)


# TODO: Should this be here?
# Updates this entity current hate
func update_bounds(bounds: Array):
	bounds = bounds


############## Specific actions


# Revive entity represented by this node
# Stops dead and plays idle animation
# Makes entity targetable again
func revive():
	print("[Entity Battle] Reviving...")
	dead = false
	$Animations.get_node("dead").stop()
	$Animations.get_node("dead").hide()
	$Animations.get_node("idle").show()
	$Animations.get_node("idle").play()


# Called when entity enters battle
# Moves sprite until its designated spot and emits finish_anim signal
func enter_scene():
	var final_pos = get_position()
	$Name.set_text(data.get_name())
	if is_player:
		self.set_position(Vector2(0, final_pos.y))
	else:
		self.set_position(Vector2(1080, final_pos.y))
	$Animations.get_node("idle").stop()
	$Animations.get_node("idle").hide()
	$Animations.get_node("move").show()
	$Animations.get_node("move").play()
	show()
	$Tween.interpolate_property(
		self, "rect_position", null, final_pos, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()


# Currently only used for when entrance animation finishes
# Stops the move animation and plays idle
func _on_Tween_tween_completed(_object: Node, _key: String):
	$Animations.get_node("move").hide()
	$Animations.get_node("move").stop()
	$Animations.get_node("idle").show()
	$Animations.get_node("idle").play()
	emit_signal("finish_anim", "Entrance")


# TODO: Refactor this
# Display correct numbers when this entity takes damage
# Or heals HP or heals MP or both
func take_damage(value, type):
	print("[ENTITY BATTLE] Taking damage, value=" + str(value) + ", type=" + str(type))
	if type == -1:
		$Damage.text = "MISS"
		$Damage.self_modulate = Color(255, 255, 255)
	elif typeof(value) == TYPE_ARRAY:
		for val in value:
			type = val[1]
			val = val[0]
			var bad_heal = str(val) == "-0"
			$Damage.text = str(val)
			if type >= 0:
				if val < 0 or bad_heal:
					val = abs(val)
					$Damage.text = "+" + str(val)
					if type == 0:
						$Damage.self_modulate = Color(0, 255, 30)
					else:
						$Damage.text = $Damage.text + "!"
						$Damage.self_modulate = Color(0, 100, 0)
				else:
					if type == 0:
						$Damage.self_modulate = Color(255, 255, 255)
					else:
						$Damage.text = $Damage.text + "!"
						$Damage.self_modulate = Color(255, 100, 0)
			else:
				if val < 0 or bad_heal:
					val = abs(val)
					$Damage.text = "+" + str(val)
					$Damage.self_modulate = Color(0, 0, 255)
				else:
					$Damage.self_modulate = Color(125, 0, 160)
	else:
		var bad_heal = str(value) == "-0"
		$Damage.text = str(value)
		if type >= 0:
			if value < 0 or bad_heal:
				value = abs(value)
				$Damage.text = "+" + str(value)
				if type == 0:
					$Damage.self_modulate = Color(0, 255, 30)
				else:
					$Damage.text = $Damage.text + "!"
					$Damage.self_modulate = Color(0, 100, 0)
			else:
				if type == 0:
					$Damage.self_modulate = Color(255, 255, 255)
				else:
					$Damage.text = $Damage.text + "!"
					$Damage.self_modulate = Color(255, 100, 0)
		else:
			if value < 0 or bad_heal:
				value = abs(value)
				$Damage.text = "+" + str(value)
				$Damage.self_modulate = Color(0, 0, 255)
			else:
				$Damage.self_modulate = Color(125, 0, 160)

	$Damage.show()
	$AnimationPlayer.play("Damage")
