extends Button

var targets = []
signal target_picked


# TODO: Make this work for lanes
func _on_Activate_Targets(skill_type: String):
	"""
		Current selected skill has target of 'ALL'
		If offensive, targets all enemies by default
		If not, targets all players
	"""
	print("[TARGETS] Activating all")
	self.disabled = false
	self.set_focus_mode(2)
	if skill_type == "OFFENSE" and self.get_name() == "Enemies":
		self.grab_focus()
	elif skill_type != "OFFENSE" and self.get_name() == "Players":
		self.grab_focus()


func _on_Deactivate_Targets():
	"""
		Untargets entity
	"""
	print("[TARGETS] Deactivating all")
	self.disabled = true
	self.set_focus_mode(0)
	_on_All_focus_exited()


func _on_All_focus_entered():
	"""
		Invisible button has focus: targets all children of this node
	"""
	print("[TARGETS] All enter ", get_name())
	for c in get_children():
		if c.data != null and not c.dead:
			c._on_Entity_focus_entered()
			targets.append(c.get_id())
	self.grab_focus()


func _on_All_focus_exited():
	"""
		Invisible button lost focus: remove all childrens of this node from target
	"""
	print("[TARGETS] All exit ", get_name())
	for c in get_children():
		c._on_Entity_focus_exited()
	targets = []


func _on_All_pressed():
	"""
		Invisible button has been pressed:
		Send target_picked signal with selected targets
	"""
	emit_signal("target_picked", targets)


func _on_Focus_First(is_ress: bool):
	"""
		Decides which of the children should be the default target for an action
		If it is a ressurection skill, targets the first dead player by default
	"""
	for c in get_children():
		if c.data != null and (not c.dead or (c.dead and c.data.tipo == "Player" and is_ress)):
			c.grab_focus()
			break
