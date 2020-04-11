extends KinematicBody2D

# Movement speed
const SPEED = 13500
var velocity = Vector2(0,0)
var inbody = null
var interacting = false

export(Array) var dialogues 

# Initializes player on map - sets position and camera
func _initialize():
	if GLOBAL.POSITION:
		position = GLOBAL.POSITION
	$AnimatedSprite.animation = "walk_down"
	self.set_z_index(1)


# Deals with input and moves player
func _physics_process(delta):
	velocity = Vector2(0,0)
	move_and_slide(velocity*delta)
	
	if inbody and Input.is_action_just_pressed("ui_accept") and not interacting:
		print("tô entrando onde nã doevia")
		GLOBAL.play_dialogues(dialogues, self)
		interacting = true
		inbody.stop.append(self)
		

func _on_Dialogue_Ended():
	print("cabô")
	inbody.stop.pop_front()
	interacting = false

func _on_Interactable_body_entered(body):
	if body.is_in_group("player"):
		inbody = body


func _on_Interactable_body_exited(body):
	if body.is_in_group("player"):
		inbody = null
