extends StaticBody2D


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		self.modulate.a = 0.5


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		self.modulate.a = 1.0
