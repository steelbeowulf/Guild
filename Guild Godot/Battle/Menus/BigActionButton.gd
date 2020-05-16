extends "res://Battle/Apply.gd"
var item_picked = null

signal action_picked

func _ready():
	for c in $Targets/ItemContainer/HBoxContainer/Itens.get_children():
		c.connect("target_picked", self, "_on_Item_Picked")
	for c in $Targets/PlayerContainer.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
		c.disabled = true
	for c in $Targets/EnemiesContainer.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
		c.disabled = true

func connect_targets(list_players, list_enemies, manager):
	var id = 0
	var img
	for e in $Targets/EnemiesContainer.get_children():
		if id < len(list_enemies):
			img = list_enemies[id]
			e.set_global_position(img.get_global_position())
			e.connect("focus_entered", img, "turn")
			e.connect("focus_exited", img, "end_turn")
			e.connect("focus_entered", manager, "manage_hate", [0, id])
			e.connect("focus_exited", manager, "hide_hate")  
			id += 1
	id = 0
	for e in $Targets/PlayerContainer.get_children():
		if id < len(list_players):
			img = list_players[id]
			e.set_global_position(img.get_global_position())
			e.connect("focus_entered", img, "turn")
			e.connect("focus_exited", img, "end_turn")  
			id += 1

func hide_stuff():
	for c in get_parent().get_children():
		c.show()
	$Targets.hide()

func _on_Target_Picked(target):
	if item_picked != null:
		target = [item_picked, target]
		emit_signal("action_picked", self.text, target)
		$Targets/ItemContainer.hide()
		$Targets/PlayerContainer.hide()
		$Targets/EnemiesContainer.hide()

func _on_Action_pressed():
	$Targets.show()
	$Targets/ItemContainer.show()
	$Targets/PlayerContainer.show()
	$Targets/EnemiesContainer.show()
	#re-enabling focus on menu
	for e in $Targets/ItemContainer/HBoxContainer/Itens.get_children():
		e.set_focus_mode(2)
	get_node("Targets/ItemContainer/HBoxContainer/Itens/0").grab_focus()
	for e in $Targets/EnemiesContainer.get_children():
		e.disabled = true
	for p in $Targets/PlayerContainer.get_children():
		p.disabled = true



func _on_Item_Picked(item):
	#removing focus on options of the menu, preventing the focus to go on unwanted places
	for e in $Targets/ItemContainer/HBoxContainer/Itens.get_children():
		e.disabled = true
		e.set_focus_mode(0)
	item_picked = item
	var ress = false
	item = LOADER.List[int(item)]
	if item.get_type() == "RESSURECTION":
		ress = true
	if item.get_target() == "ALL":
		for e in $Targets/EnemiesContainer.get_children():
			e.set_focus_mode(2)
		for p in $Targets/PlayerContainer.get_children():
			p.set_focus_mode(2)
		$Targets/EnemiesContainer/"E0".set_all()
		$Targets/EnemiesContainer/"E0".disabled = false
		$Targets/EnemiesContainer/"E0".show()
		$Targets/PlayerContainer/"P0".set_all()
		$Targets/PlayerContainer/"P0".disabled = false
		$Targets/PlayerContainer/"P0".show()
	else:
		for e in $Targets/EnemiesContainer.get_children():
			e.disabled = false
		for p in $Targets/PlayerContainer.get_children():
			p.disabled = false
	$Targets/PlayerContainer/"P0".grab_focus()

func _on_4_focus_exited():
	if Input.is_action_pressed("ui_down"):
		$Targets/ItemContainer.scroll_vertical += 20
	if Input.is_action_pressed("ui_up"):
		$Targets/ItemContainer.scroll_vertical -= 20
	if Input.is_action_pressed("ui_cancel"):
		$Targets/ItemContainer.scroll_vertical = 0
