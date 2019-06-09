extends VBoxContainer

signal turn_finished

func _ready():
	print("STARTING...")
	for c in get_children():
		print("T")
		c.connect("action_picked", self, "_on_Action_Picked")

func _on_Action_Picked(action, target):
	print("A")
	get_parent().set_current_action(action)
	print("B")
	get_parent().set_current_target(target)
	print("C")
	emit_signal("turn_finished")