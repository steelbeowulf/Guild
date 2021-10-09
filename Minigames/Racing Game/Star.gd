extends Area2D

signal score_plus

func _ready():
	connect("score_plus",get_parent(),"change_score")

func _on_Star_body_entered(body):
	emit_signal("score_plus", 5)
	print("Mais pontinho")
	queue_free()


