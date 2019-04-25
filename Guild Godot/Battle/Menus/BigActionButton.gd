extends Button
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

func hide_stuff():
	for c in get_parent().get_children():
		c.show()
	$Targets.hide()

func _on_Target_Picked(target):
	if item_picked != null:
		target = [item_picked, target]
		emit_signal("action_picked", self.text, target)
		$Targets/HBoxContainer.hide()
		#self.disabled = false

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
	for e in $Targets/HBoxContainer/Enemies.get_children():
		e.disabled = false
	for p in $Targets/HBoxContainer/Players.get_children():
		p.disabled = false
	$Targets/HBoxContainer/Players/"1".grab_focus()