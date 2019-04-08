extends Button

signal target_picked

func _on_Target_pressed():
	emit_signal("target_picked", self.text)
