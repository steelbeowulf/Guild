extends Area2D

signal slip

func _ready():
	connect("slip",self.get_parent(),"car_slipped")

#when the player entered the car will slip
func _on_Oil_body_entered(body):
	emit_signal("slip")
	print("Opa vou escorregar!")
	queue_free()

