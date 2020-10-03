extends Button

signal action_picked
signal activate_targets
signal deactivate_targets
signal activate_targets_all
signal deactivate_targets_all

export(String) var action_type : String
var subaction : int = -1
var targets : PoolIntArray = []

func _ready():
	action_type = get_name()
	self.text = get_name()
	self.set_focus_next(NodePath("SubActions/0"))
	for c in $ScrollContainer/SubActions.get_children():
		c.connect("subaction_picked", self, "_on_SubAction_Picked")
		c.connect("focus_entered", self, "_on_Focus_Entered", [c])

func _on_SubAction_Picked(subaction_arg: int) -> void:
	subaction = subaction_arg
	$ScrollContainer.hide()
	if action_type == "Lane":
		emit_signal("action_picked", action_type, subaction, [])
		return
	else:
		#removing focus on options of the menu, preventing the focus to go on unwanted places
		for e in $ScrollContainer/SubActions.get_children():
			e.disabled = true
			e.set_focus_mode(0)
		var skitem = LOADER.List[subaction_arg]
		
		if skitem.get_target() == "ALL":
			emit_signal("activate_targets_all")
		else:
			emit_signal("activate_targets")


func hide_stuff():
	for c in get_parent().get_children():
		c.show()
	$ScrollContainer.hide()
	emit_signal("deactivate_targets")
	emit_signal("deactivate_targets_all")

func _on_Action_pressed():
	print("ACTION PRESSED ", action_type)
	if action_type == "Run":
		emit_signal("action_picked", action_type, 0, [])
		return
	elif action_type == "Attack":
		subaction = 1
		emit_signal("activate_targets")
	else:
		for c in get_parent().get_children():
			if c.get_name() != action_type:
				c.hide_stuff()
		$ScrollContainer.show()
		for t in get_node("ScrollContainer/SubActions").get_children():
			if t.visible:
				t.grab_focus()
				break

func _on_Targets_Picked(target_args: PoolIntArray):
	print("ACTIONBUTTON TARGETS")
	print(subaction)
	print(targets)
	targets = target_args
	print(action_type)
	if subaction != -1:
		$ScrollContainer.hide()
		emit_signal("deactivate_targets")
		emit_signal("deactivate_targets_all")
		emit_signal("action_picked", action_type, subaction, targets)


func connect_targets(list_players: Array, list_enemies: Array, manager: Node, allPlayers: Button, allEnemies: Button) -> void:
	var id = 0
	var img
	for e in list_enemies:
		e.connect("focus_entered", manager, "manage_hate", [0, id])
		e.connect("focus_exited", manager, "hide_hate")
		e.connect("target_picked", self, "_on_Targets_Picked")  
		self.connect("activate_targets", e, "_on_Activate_Targets")
		self.connect("deactivate_targets", e, "_on_Deactivate_Targets")
		id += 1
	id = 0
	for p in list_players:
		p.connect("target_picked", self, "_on_Targets_Picked")  
		self.connect("activate_targets", p, "_on_Activate_Targets")
		self.connect("deactivate_targets", p, "_on_Deactivate_Targets")
		id += 1
	self.connect("activate_targets_all", allPlayers, "_on_Activate_Targets")
	self.connect("activate_targets_all", allEnemies, "_on_Activate_Targets")
	self.connect("deactivate_targets_all", allPlayers, "_on_Deactivate_Targets")
	self.connect("deactivate_targets_all", allEnemies, "_on_Deactivate_Targets")
	allPlayers.connect("target_picked", self, "_on_Targets_Picked") 
	allEnemies.connect("target_picked", self, "_on_Targets_Picked") 

func _on_Focus_Entered(button):
	var num = int(button.get_name())
	print(num)
	$ScrollContainer.scroll_vertical = num * 30
