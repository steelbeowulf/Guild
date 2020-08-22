extends "res://Battle/Apply.gd"
var tool_picked = null
var action = null

signal action_picked

func _ready():
	action = get_name()
	for c in $ToolContainer/HBoxContainer/Tools.get_children():
		c.connect("tool_picked", self, "_on_Tool_Picked")
	for c in $PlayerContainer.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
		c.disabled = true
	for c in $EnemiyContainer.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
		c.disabled = true

func connect_targets(list_players, list_enemies, manager):
	var id = 0
	var img
	for e in $EnemiesContainer.get_children():
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

func hide_stuff():
	for c in get_parent().get_children():
		c.show()
	$ToolContainer.hide()
	$PlayerContainer.hide()
	$EnemyContainer.hide()

func _on_Target_Picked(target):
	if tool_picked != null:
		target = tool_picked+";"+target
		emit_signal("action_picked", self.text, target)
		$ItemContainer.hide()
		$PlayerContainer.hide()
		$EnemiesContainer.hide()

func _on_Action_pressed():
	$ItemContainer.show()
	$PlayerContainer.show()
	$EnemiesContainer.show()
	#re-enabling focus on menu
	for e in $ItemContainer/HBoxContainer/Tools.get_children():
		e.set_focus_mode(2)
	get_node("ItemContainer/HBoxContainer/Tools/0").grab_focus()
	for e in $EnemiesContainer.get_children():
		e.disabled = true
	for p in $PlayerContainer.get_children():
		p.disabled = true

func _on_Tool_Picked(skitem_id: String) -> void:
	#removing focus on options of the menu, preventing the focus to go on unwanted places
	for e in $ToolContainer/HBoxContainer/Tools.get_children():
		e.disabled = true
		e.set_focus_mode(0)
	tool_picked = skitem_id
	var skitem = LOADER.List[int(skitem_id)]
	if skitem.get_target() == "ALL":
		for e in $EnemiesContainer.get_children():
			e.set_focus_mode(2)
		for p in $PlayerContainer.get_children():
			p.set_focus_mode(2)
		$EnemiesContainer/"E0".set_all()
		$EnemiesContainer/"E0".disabled = false
		$EnemiesContainer/"E0".show()
		$PlayerContainer/"P0".set_all()
		$PlayerContainer/"P0".disabled = false
		$PlayerContainer/"P0".show()
	else:
		for e in $EnemiesContainer.get_children():
			e.disabled = false
		for p in $PlayerContainer.get_children():
			p.disabled = false
	$PlayerContainer/"P0".grab_focus()

func _on_4_focus_exited():
	if Input.is_action_pressed("ui_down"):
		$ToolContainer.scroll_vertical += 20
	if Input.is_action_pressed("ui_up"):
		$ToolContainer.scroll_vertical -= 20
	if Input.is_action_pressed("ui_cancel"):
		$ToolContainer.scroll_vertical = 0
