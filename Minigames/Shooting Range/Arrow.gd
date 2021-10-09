extends Area2D

var velocity = Vector2(0,0)

func _physics_process(delta):
	translate(velocity*delta)

func _on_Arrow_area_entered(area):
	AUDIO.play_se("ARROW")
	queue_free()
