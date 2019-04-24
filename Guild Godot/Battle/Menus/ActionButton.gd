extends Button

signal action_picked

func _ready():
	self.set_focus_next(NodePath("Targets/0"))
	for c in $Targets.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")

func _on_Target_Picked(target):
	emit_signal("action_picked", self.text, target)
	$Targets.hide()

func hide_stuff():
	$Targets.hide()

func _on_Action_pressed():
	for c in get_parent().get_children():
		if c != self:
			c.hide_stuff()
	$Targets.show()
	for t in get_node("Targets").get_children():
		if t.visible:
			t.grab_focus()
			break
