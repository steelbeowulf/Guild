extends "res://Battle/Apply.gd"
var item_picked = null

signal action_picked

func _ready():
	for c in $Targets/HBoxContainer/Itens.get_children():
		c.connect("target_picked", self, "_on_Item_Picked")
	for c in $Targets/HBoxContainer/Players.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
		c.disabled = true
	for c in $Targets/HBoxContainer/Enemies.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
		c.disabled = true

func connect_targets(list_players, list_enemies, manager):
	var id = 0
	var img
	for e in $Targets/HBoxContainer/Enemies.get_children():
		if id < len(list_enemies):
			img = list_enemies[id]
			e.connect("focus_entered", img, "turn")
			e.connect("focus_exited", img, "end_turn")
			e.connect("focus_entered", manager, "manage_hate", [0, id])
			e.connect("focus_exited", manager, "manage_hate", [1, id])      
			id += 1
	id = 0
	for e in $Targets/HBoxContainer/Players.get_children():
		if id < len(list_players):
			img = list_players[id]
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
		$Targets/HBoxContainer.hide()
		print("emitindo sinal action_picked do "+str(self.text))

func _on_Action_pressed():
	$Targets.show()
	$Targets/HBoxContainer.show()
	get_node("Targets/HBoxContainer/Itens/0").grab_focus()
	for e in $Targets/HBoxContainer/Enemies.get_children():
		e.disabled = true
	for p in $Targets/HBoxContainer/Players.get_children():
		p.disabled = true

func _on_Item_Picked(item):
	item_picked = item
	var ress = false
	item = LOADER.List[int(item)]
	if item.get_type() == "RESSURECTION":
		ress = true
	if item.get_target() == "ALL":
		for e in $Targets/HBoxContainer/Enemies.get_children():
			e.hide()
		for p in $Targets/HBoxContainer/Players.get_children():
			p.hide()
		$Targets/HBoxContainer/Enemies/"E0".set_text("All Enemies")
		$Targets/HBoxContainer/Enemies/"E0".disabled = false
		$Targets/HBoxContainer/Enemies/"E0".show()
		$Targets/HBoxContainer/Players/"P0".set_text("All Players")
		$Targets/HBoxContainer/Players/"P0".disabled = false
		$Targets/HBoxContainer/Players/"P0".show()
	else:
		for e in $Targets/HBoxContainer/Enemies.get_children():
			e.disabled = false
		for p in $Targets/HBoxContainer/Players.get_children():
			p.disabled = false
	$Targets/HBoxContainer/Players/"P0".grab_focus()