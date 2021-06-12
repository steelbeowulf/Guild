extends KinematicBody2D

# Movement speed
const SPEED = 13500
const SCALE = 0.3
var velocity = Vector2(0,0)

# List of objects stopping player from moving
onready var stop = []

func set_animations(sprite, animations):
	$Animations.scale = Vector2(SCALE, SCALE)
	var img = sprite['path']
	var vf = sprite['vframes']
	var hf = sprite['hframes']
	var sc = sprite['scale']
	
	for k in animations.keys():
		var v = animations[k]
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
		animation.hide()
		animation.playing = false
		$Animations.add_child(animation)

func play(name):
	if $Animations.get_node(name).playing:
		return
	print("[CARA MUNDO] playing animation "+name)
	var node = $Animations
	for c in $Animations.get_children():
		c.playing = false
		c.hide()
 	node.get_node(name).show()
	node.get_node(name).play(true)

# Initializes player on map - sets position and camera
func _initialize():
	if LOCAL.POSITION:
		position = LOCAL.POSITION
	self.set_z_index(1)
	var margin = get_parent().get_parent().get_map_margin()
	$Camera2D.set_limit(MARGIN_BOTTOM, margin[0])
	$Camera2D.set_limit(MARGIN_LEFT, margin[1])
	$Camera2D.set_limit(MARGIN_TOP, margin[2])
	$Camera2D.set_limit(MARGIN_RIGHT, margin[3])
	print("[PLAYER POSITION] "+str(position))
	var Play = GLOBAL.PLAYERS[0]
	set_animations(Play.sprite, Play.animations)
	play("idle")


# Deals with input and moves player
func _physics_process(delta):
	velocity = Vector2(0,0)
	if stop == []:
		if Input.is_action_pressed("ui_up"):
			velocity.y = -SPEED
			$Head.rotation_degrees = 0
		elif Input.is_action_pressed("ui_down"):
			velocity.y = SPEED
			$Head.rotation_degrees = 180
		if Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$Animations.scale.x = -SCALE
			$Head.rotation_degrees = 270
		elif Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$Animations.scale.x = SCALE
			$Head.rotation_degrees = 90

	if velocity == Vector2(0,0):
		play("idle")
	else:
		AUDIO.play_se("GRASS", -16)
		play("move")

	move_and_slide(velocity*delta)


# Returns direction player is facing
func dir():
	return str($Head.rotation_degrees)


func _on_Battle_body_entered(body):
	if body.is_in_group("enemy"):
		print("[CARA MUNDO] Entered body is enemy")
		body.in_encounter()


func _on_Battle_body_exited(body):
	if body.is_in_group("enemy"):
		body.off_encounter()
