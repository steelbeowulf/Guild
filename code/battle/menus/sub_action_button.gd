extends Button

signal subaction_picked
onready var action_id : int = int(get_name())

func _on_SubAction_pressed():
	emit_signal("subaction_picked", action_id)
