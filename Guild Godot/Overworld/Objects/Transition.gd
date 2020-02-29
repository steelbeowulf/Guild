extends Node2D

export (int) var next

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and not GLOBAL.entering_battle:
		GLOBAL.TRANSITION = GLOBAL.MAP
		get_parent().get_parent().transition(next)