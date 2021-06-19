extends Area2D

var array_position: int 
signal hit

func _ready():
	connect("hit",get_parent(),"change_hits_counter")

#if the arrow hit the target we need to reset the target position in the positionx(y)_array 
func _on_Target_area_entered(area):
	get_parent().positionx_array[array_position] = 0
	get_parent().positiony_array[array_position] = 0
	emit_signal("hit")
	queue_free()

#the target disappear after 5 seconds
func _on_SelfDestruction_Timer_timeout():
	queue_free()
