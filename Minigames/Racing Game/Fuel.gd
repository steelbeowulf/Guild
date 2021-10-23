extends Area2D

signal fuel_catch

func _ready():
	connect("fuel_catch", self.get_parent(),"fuel_plus")

#when the player entered in the fuel's area he gets more 1 fuel to use the boost
func _on_Fuel_body_entered(body):
	emit_signal("fuel_catch")
	print("Pego gasolina")
	queue_free()
