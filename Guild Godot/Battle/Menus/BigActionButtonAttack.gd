extends "res://Battle/Apply.gd"

signal action_picked

func _ready():
	for c in $Targets/HBoxContainer/Players.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
	for c in $Targets/HBoxContainer/Enemies.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")

func hide_stuff():
	for c in get_parent().get_children():
		c.show()
	$Targets.hide()

func _on_Target_Picked(target):
	target = [1, target]
	emit_signal("action_picked", self.text, target)
	$Targets/HBoxContainer.hide()
	print("emitindo sinal action_picked do "+str(self.text))

func _on_Action_pressed():
	$Targets.show()
	$Targets/HBoxContainer.show()
	for b in $Targets/HBoxContainer/Enemies.get_children():
		if not b.disabled and b.visible:
			b.grab_focus()
			break