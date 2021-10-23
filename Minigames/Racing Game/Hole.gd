extends Area2D

signal death

func _ready():
	connect("death",get_parent(),"player_death")

func _on_Hole_body_entered(body):
	emit_signal("death")
	print("Vou morrer bixo!")
	queue_free()
