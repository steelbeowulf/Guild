extends Button

signal action_picked

func _ready():
	for c in $Targets.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")

func _on_Target_Picked(target):
	emit_signal("action_picked", self.text, target)
	$Targets.hide()

func _on_Action_pressed():
	$Targets.show()
