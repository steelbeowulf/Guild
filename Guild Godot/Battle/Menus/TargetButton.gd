extends Button

signal target_picked

func _on_Target_pressed():
	var target_id : int = int(get_name())
	emit_signal("target_picked", [target_id])

func _on_Target_focus_entered():
	$Sprite.show()

func _on_Target_focus_exited():
	$Sprite.hide()
