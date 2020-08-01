extends Button

signal target_picked
signal target_selected

func _on_ItemSlot0_pressed():
	emit_signal("target_picked")

func _on_ItemSlot0_focus_entered():
	emit_signal("target_selected")