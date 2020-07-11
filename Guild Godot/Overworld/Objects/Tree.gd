extends StaticBody2D

export var TYPE = 0
export var next = 0
var player

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		self.modulate.a = 0.5
		player = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		self.modulate.a = 1.0
		player = false

func _process(delta):
	if TYPE != 0 and player and Input.is_action_just_pressed("ui_accept"):
		GLOBAL.TRANSITION = GLOBAL.MAP
		get_parent().get_parent().get_parent().transition(next)