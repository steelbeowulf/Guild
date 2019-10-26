extends VBoxContainer

signal turn_finished

func _ready():
	for c in get_children():
		c.connect("action_picked", self, "_on_Action_Picked")

func _on_Action_Picked(action, target):
	get_parent().set_current_action(action)
	get_parent().set_current_target(target)
	emit_signal("turn_finished")