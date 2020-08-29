extends Button

signal target_picked
var target_id : int = int(get_name())

func _on_Target_pressed():
	emit_signal("target_picked", target_id)

func _on_Target_focus_entered():
	$Sprite.show()

func _on_Target_focus_exited():
	$Sprite.hide()