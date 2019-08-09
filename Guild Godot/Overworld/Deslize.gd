extends Node2D

onready var inbody = null
onready var velocity = Vector2(0,0)
const MOVEMENT = 8000

onready var directions = {'0':Vector2(0,-1), '90':Vector2(1,0), 
'180':Vector2(0,1), '270':Vector2(-1,0)}

func _physics_process(delta):
	if inbody:
		if inbody.velocity == Vector2(0,0) and inbody.is_in_group("player"):
			inbody.stop.pop_front()
		print("movendo com vel="+str(velocity))
		inbody.move_and_slide(MOVEMENT*velocity*delta)

func _on_Area2D_body_entered(body):
	inbody = body
	velocity = inbody.velocity.normalized()
	if body.is_in_group("player"):
		body.stop.append(0)
		velocity = directions[body.dir()]
		print("entrando, body="+str(body.stop))

func _on_Area2D_body_exited(body):
	if body == inbody:
		inbody = null
		if body.is_in_group("player"):
			body.stop.pop_front()
			print("saindo, body="+str(body.stop))
