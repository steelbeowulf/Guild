extends Area2D

var health
func _ready():
	health = 10

func _process(delta):
	if health <= 0:
		hide()

func _on_Button_pressed():
	health = health - 1
	print(health)


