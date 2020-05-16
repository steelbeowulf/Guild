extends Button

signal target_picked

func _on_Target_pressed():
	emit_signal("target_picked", get_name())

func _on_Target_focus_entered():
	$Sprite.show()

func _on_Target_focus_exited():
	$Sprite.hide()