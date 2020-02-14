extends Button

signal target_picked

func _on_ItemSlot0_pressed():
	emit_signal("target_picked", get_text())
