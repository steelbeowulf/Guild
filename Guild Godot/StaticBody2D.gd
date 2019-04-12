extends StaticBody2D

var health

func _ready():
	health = 10
	

func _process(delta):
	if health < 0:
		hide()