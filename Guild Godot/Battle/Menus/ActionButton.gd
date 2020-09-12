extends Button

signal action_picked

export(String) var action_type : String
var subaction : int = -1
var targets : PoolIntArray = []

func _ready():
	action_type = get_name()
	self.text = get_name()
	self.set_focus_next(NodePath("SubActions/0"))
	for c in $SubActions.get_children():
		c.connect("subaction_picked", self, "_on_SubAction_Picked")
	for c in $PlayerContainer.get_children():
		c.connect("target_picked", self, "_on_Targets_Picked")
		c.disabled = true
	for c in $EnemyContainer.get_children():
		c.connect("target_picked", self, "_on_Targets_Picked")
		c.disabled = true


func _on_SubAction_Picked(subaction_arg: int) -> void:
	subaction = subaction_arg
	$SubActions.hide()
	if action_type == "Lane":
		emit_signal("action_picked", action_type, subaction, [])
		return
	else:
		#removing focus on options of the menu, preventing the focus to go on unwanted places
		for e in $SubActions.get_children():
			e.disabled = true
			e.set_focus_mode(0)
		var skitem = LOADER.List[subaction_arg]
		if skitem.get_target() == "ALL":
			for e in $EnemyContainer.get_children():
				e.set_focus_mode(2)
				e.show()
				e.disabled = false
			for p in $PlayerContainer.get_children():
				p.set_focus_mode(2)
				p.show()
				p.disabled = false
				#$EnemyContainer/"0".set_all()
				#$EnemyContainer/"0".disabled = false
				#$EnemyContainer/"0".show()
				#$PlayerContainer/"0".set_all()
				#$PlayerContainer/"0".disabled = false
				#$PlayerContainer/"0".show()
		else:
			for e in $EnemyContainer.get_children():
				e.set_focus_mode(2)
				e.show()
				e.disabled = false
			for p in $PlayerContainer.get_children():
				p.set_focus_mode(2)
				p.show()
				p.disabled = false
		$PlayerContainer/"-1".grab_focus()


func hide_stuff():
	for c in get_parent().get_children():
		c.show()
	$SubActions.hide()
	$PlayerContainer.hide()
	$EnemyContainer.hide()

func _on_Action_pressed():
	if action_type == "Run":
		emit_signal("action_picked", action_type, 0, [])
		return
	elif action_type == "Attack":
		subaction = 1
		$PlayerContainer.show()
		$EnemyContainer.show()
	else:
		for c in get_parent().get_children():
			if c != self:
				c.hide_stuff()
		$SubActions.show()
		for t in get_node("SubActions").get_children():
			if t.visible:
				t.grab_focus()
				break

#func _on_Action_pressed():
#	$ItemContainer.show()
#	$PlayerContainer.show()
#	$EnemyContainer.show()
#	#re-enabling focus on menu
#	for e in $ItemContainer/HBoxContainer/Tools.get_children():
#		e.set_focus_mode(2)
#	get_node("ItemContainer/HBoxContainer/Tools/0").grab_focus()
#	for e in $EnemyContainer.get_children():
#		e.disabled = true
#	for p in $PlayerContainer.get_children():
#		p.disabled = true

func _on_Targets_Picked(targets: PoolIntArray):
	print("ACTIONBUTTON TARGETS")
	print(subaction)
	print(targets)
	if subaction != -1:
		$SubActions.hide()
		$PlayerContainer.hide()
		$EnemyContainer.hide()
		emit_signal("action_picked", action_type, subaction, targets)


func connect_targets(list_players: Array, list_enemies: Array, manager: Node) -> void:
	var id = 0
	var img
	for e in $EnemyContainer.get_children():
		if id < len(list_enemies):
			img = list_enemies[id]
			e.set_global_position(img.get_global_position())
			e.connect("focus_entered", img, "turn")
			e.connect("focus_exited", img, "end_turn")
			e.connect("focus_entered", manager, "manage_hate", [0, id])
			e.connect("focus_exited", manager, "hide_hate")  
			id += 1
	id = 0
	for p in $PlayerContainer.get_children():
		if id < len(list_players):
			img = list_players[id]
			p.set_global_position(img.get_global_position())
			p.connect("focus_entered", img, "turn")
			p.connect("focus_exited", img, "end_turn")  
			id += 1


#func _on_4_focus_exited():
#	if Input.is_action_pressed("ui_down"):
#		$ToolContainer.scroll_vertical += 20
#	if Input.is_action_pressed("ui_up"):
#		$ToolContainer.scroll_vertical -= 20
#	if Input.is_action_pressed("ui_cancel"):
#		$ToolContainer.scroll_vertical = 0
