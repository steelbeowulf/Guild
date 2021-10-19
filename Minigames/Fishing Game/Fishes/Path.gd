extends Path2D

var initial_position = Vector2(0,0)

func _ready():
	position = initial_position

func _end():
	print("morte!")
	queue_free()