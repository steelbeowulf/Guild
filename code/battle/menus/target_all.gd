extends Button

signal target_picked

var targets = []


# TODO: Make this work for lanes
# Current selected skill has target of 'ALL'
# If offensive, targets all enemies by default
# If not, targets all players
func _on_Targets_activated(skill_type: String):
	print("[TARGETS] Activating all")
	self.disabled = false
	self.set_focus_mode(2)
	if skill_type == "OFFENSE" and self.get_name() == "Enemies":
		self.grab_focus()
	elif skill_type != "OFFENSE" and self.get_name() == "Players":
		self.grab_focus()


# Untargets entity
func _on_Targets_deactivated():
	print("[TARGETS] Deactivating all")
	self.disabled = true
	self.set_focus_mode(0)
	_on_All_focus_exited()


# Invisible button has focus: targets all children of this node
func _on_All_focus_entered():
	print("[TARGETS] All enter ", get_name())
	for c in get_children():
		if c.data != null and not c.dead:
			c.on_entity_focus_entered()
			targets.append(c.get_id())
	self.grab_focus()


# Invisible button lost focus: remove all childrens of this node from target
func _on_All_focus_exited():
	print("[TARGETS] All exit ", get_name())
	for c in get_children():
		c.on_entity_focus_exited()
	targets = []


# Invisible button has been pressed:
# Send target_picked signal with selected targets
func _on_All_pressed():
	emit_signal("target_picked", targets)


# Decides which of the children should be the default target for an action
# If it is a ressurection skill, targets the first dead player by default
func _on_first_focus(is_ress: bool):
	for c in get_children():
		if c.data != null and (not c.dead or (c.dead and c.data.type == "Player" and is_ress)):
			c.grab_focus()
			break
