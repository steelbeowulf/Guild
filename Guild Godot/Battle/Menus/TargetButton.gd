extends Button

signal target_picked
var all = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		all = false

func _on_Target_pressed():
	emit_signal("target_picked", get_name())
	all = false

func _on_Target_focus_entered():
	$Sprite.show()
	if all:
		for target in get_parent().get_children():
			target.get_node("Sprite").show()

func _on_Target_focus_exited():
	$Sprite.hide()
	if all:
		for target in get_parent().get_children():
			target.get_node("Sprite").hide()

func set_all():
	all = true