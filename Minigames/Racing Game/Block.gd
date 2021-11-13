extends StaticBody2D

func _on_Area2D_body_entered(body):
	AUDIO.play_se("BLOCK")
