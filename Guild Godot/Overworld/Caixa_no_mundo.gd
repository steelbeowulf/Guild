extends KinematicBody2D

const MOVEMENT = 5200

onready var can_interact = false
onready var velocity = Vector2(0,0)

func _physics_process(delta):
	if can_interact and Input.is_action_pressed("ui_accept"):
		move_and_slide(velocity*MOVEMENT*delta)

func _on_Down_area_entered(area):
	if area.is_in_group("head"):
		can_interact = true
		velocity = Vector2(0,-1)


func _on_Down_area_exited(area):
	if area.is_in_group("head"):
		can_interact = false


func _on_Up_area_entered(area):
	if area.is_in_group("head"):
		can_interact = true
		velocity = Vector2(0,1)


func _on_Up_area_exited(area):
	if area.is_in_group("head"):
		can_interact = false


func _on_Right_area_entered(area):
	if area.is_in_group("head"):
		can_interact = true
		velocity = Vector2(-1,0)


func _on_Right_area_exited(area):
	if area.is_in_group("head"):
		can_interact = false

func _on_Left_area_entered(area):
	if area.is_in_group("head"):
		can_interact = true
		velocity = Vector2(1,0)


func _on_Left_area_exited(area):
	if area.is_in_group("head"):
		can_interact = false