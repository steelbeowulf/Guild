extends "res://Battle/Apply.gd"

signal action_picked

func _ready():
	for c in $Targets/HBoxContainer/Players.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
	for c in $Targets/HBoxContainer/Enemies.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")

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
	target = [1, target]
	emit_signal("action_picked", self.text, target)
	$Targets/HBoxContainer.hide()
	


func _on_Action_pressed():
	$Targets.show()
	$Targets/HBoxContainer.show()
	for b in $Targets/HBoxContainer/Enemies.get_children():
		if not b.disabled and b.visible:
			b.grab_focus()
			break