extends KinematicBody2D

# Movement speed
const SPEED = 13500
var velocity = Vector2(0,0)
var inbody = null
var interacting = false
var delay = 0.0
var npc = null

export(int) var id


func _ready():
	npc = LOCAL.get_npc(id)
	set_animations(npc.get_sprite(), npc.get_animation())

# Initializes position
func set_animations(sprite, animations):
	var img = sprite['path']
	var vf = sprite['vframes']
	var hf = sprite['hframes']
	var sc = sprite['scale']
	
	for k in animations.keys():
		var v = animations[k]
		var animation = Sprite.new()
		animation.texture = load(img)
		animation.set_name(k)
		animation.set_script(load('res://code/classes/util/spritesheet.gd'))
		animation.loop = v[0]
		animation.physical_frames = v[1]
		animation.vframes = vf
		animation.hframes = hf
		animation.scale = Vector2(sc[0], sc[1])
		animation.fps = 10
		$Animations.add_child(animation)
		$Animations.get_node("idle").play(true)

# Deals with input and moves player
func _physics_process(delta):
	velocity = Vector2(0,0)
	move_and_slide(velocity*delta)
	delay = delay - delta
	if delay <= 0:
		if inbody and Input.is_action_just_pressed("ui_accept") and not interacting:
			EVENTS.start_npc_dialogue(npc.get_name(), npc.get_portrait(), npc.get_events(), self)
			interacting = true
			inbody.stop.append(self)


func on_dialogue_ended():
	inbody.stop.pop_front()
	interacting = false
	delay = 0.5


func _on_Interactable_body_entered(body):
	if body.is_in_group("player"):
		inbody = body


func _on_Interactable_body_exited(body):
	if body.is_in_group("player"):
		inbody = null
