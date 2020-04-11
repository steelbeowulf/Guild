extends KinematicBody2D

# Movement speed
const SPEED = 13500
var velocity = Vector2(0,0)
var inbody = null
var interacting = false
var delay = 0.0

export(int) var id

# Initializes position
func _ready():
	$AnimatedSprite.animation = "walk_down"
	self.set_z_index(1)


# Deals with input and moves player
func _physics_process(delta):
	velocity = Vector2(0,0)
	move_and_slide(velocity*delta)
	delay = delay - delta
	if delay <= 0:
		if inbody and Input.is_action_just_pressed("ui_accept") and not interacting:
			GLOBAL.play_dialogues(id, self)
			interacting = true
			inbody.stop.append(self)


func _on_Dialogue_Ended():
	inbody.stop.pop_front()
	interacting = false
	delay = 0.5


func _on_Interactable_body_entered(body):
	if body.is_in_group("player"):
		inbody = body


func _on_Interactable_body_exited(body):
	if body.is_in_group("player"):
		inbody = null
