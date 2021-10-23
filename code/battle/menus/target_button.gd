extends Button

signal target_picked
var target_id: int


func set_target_id(id: int):
	target_id = id


func _on_Target_pressed():
	emit_signal("target_picked", [target_id])


func _on_Target_focus_entered():
	$Sprite.show()


func _on_Target_focus_exited():
	$Sprite.hide()


func _on_Targets_activated():
	self.disabled = false
	self.set_focus_mode(2)
	self.show()
	self.grab_focus()


func _on_Targets_deactivated():
	self.disabled = true
	self.set_focus_mode(0)
	self.hide()
