extends StaticBody2D

onready var inbody = false
onready var activated = false
onready var open = false

func _update(value):
	var pos = value[1]
	value = value[0]
	self.set_global_position(pos)

func _physics_process(delta):
	if inbody:
		if Input.is_action_just_pressed("ui_accept"):
			activated = true

func _on_Area2D_area_entered(area):
	if area.is_in_group('head'):
		inbody = true


func _on_Area2D_area_exited(area):
	if area.is_in_group('head'):
		inbody = true
