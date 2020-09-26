extends Button

var targets = []
signal target_picked

func _on_Activate_Targets():
	print("ACTIVATING ALL TARGETS")
	self.disabled = false
	self.set_focus_mode(2)
	self.grab_focus()

func _on_Deactivate_Targets():
	print("DEACTIVATING ALL TARGETS")
	self.disabled = true
	self.set_focus_mode(0)
	_on_All_focus_exited()


func _on_All_focus_entered():
	print("all ennter ", get_name())
	for c in get_children():
		c._on_P0_focus_entered()
		targets.append(c.get_id())
	self.grab_focus()


func _on_All_focus_exited():
	print("all exit ", get_name())
	for c in get_children():
		c._on_P0_focus_exited()
	targets = []


func _on_All_pressed():
	print("ALL PRESED")
	emit_signal("target_picked", targets)
