extends Button

var targets = []
signal target_picked

func _on_Activate_Targets(skill_type: String):
	print("ACTIVATING ALL TARGETS")
	self.disabled = false
	self.set_focus_mode(2)
	if skill_type == "OFFENSE" and self.get_name() == "Enemies":
		self.grab_focus()
	elif skill_type != "OFFENSE" and self.get_name() == "Players":
		self.grab_focus()

func _on_Deactivate_Targets():
	print("DEACTIVATING ALL TARGETS")
	self.disabled = true
	self.set_focus_mode(0)
	_on_All_focus_exited()


func _on_All_focus_entered():
	print("all ennter ", get_name())
	for c in get_children():
		if not c.dead:
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

func _on_Focus_First(is_ress: bool):
	for c in get_children():
		if not c.dead or (c.dead and c.data.tipo == "Player" and is_ress):
			c.grab_focus()
			break
