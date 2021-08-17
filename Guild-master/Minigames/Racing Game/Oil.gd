extends Area2D

signal slip

func _ready():
	connect("slip",self.get_parent(),"car_splipped")

#when the player entered the car will slip
func _on_Fuel_body_entered(body):
	emit_signal("slip")
	print("Opa vou escorregar!")
	queue_free()
