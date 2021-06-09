extends StaticBody2D

var open = false

func _update(value):
	var pos = GLOBAL.parse_position(value[1])
	value = value[0]
	if value:
		self.visible = false
		$CollisionShape2D.disabled = true
	self.set_global_position(pos)
	
func open():
	open = true
	get_parent().get_parent().save_state("OBJ_POS", get_name(), get_global_position())
	self.visible = false
	$CollisionShape2D.disabled = true