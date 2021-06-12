extends Control

const lanes_text = ["BACK", "MID", "FRONT"]
onready var Battle : Node = get_parent()
onready var menu_state : String = ""

signal turn_finished

func _ready():
	for c in $Menu.get_children():
		c.connect("action_picked", self, "_on_Action_Picked")


# Repass info to parent
func _on_Action_Picked(action_type: String, action_id: int, targets: PoolIntArray) -> void:
	if action_type != menu_state:
		return
	var action = Action.new(action_type, action_id, targets)
	Battle.set_current_action(action)
	menu_state = ""
	emit_signal("turn_finished")

# Update State
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and menu_state != "":
		for c in $Menu.get_children():
			c.hide_stuff()
		get_node("Menu/"+str(menu_state)).disabled = false
		get_node("Menu/"+str(menu_state)).set_focus_mode(2)
		get_node("Menu/"+str(menu_state)).grab_focus()
		menu_state = ""

# Prepare actions UI
func prepare_run_action() -> void:
	menu_state = "Run"
	get_node("Menu/Run")._on_Action_pressed()

func prepare_lane_action(current_lane : int) -> void:
	menu_state = "Lane"
	
	for c in get_node("Menu/Lane/ScrollContainer/SubActions").get_children():
		c.hide()
	
	for i in range(len(lanes_text)):
		get_node("Menu/Lane/ScrollContainer/SubActions/"+str(i)).hide()
		if current_lane != i:
			var lane = get_node("Menu/Lane/ScrollContainer/SubActions/"+str(i))
			lane.show()
			lane.grab_focus()
			lane.set_text(lanes_text[i])
	
	get_node("Menu/Lane/ScrollContainer/SubActions").show()
	get_node("Menu/Lane")._on_Action_pressed()

func prepare_itens_action(inventory: Array) -> void:
	menu_state = "Item"
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Skill").hide()
	get_node("Menu/Run").hide()
	get_node("Menu/Item").disabled = true
	get_node("Menu/Item").set_focus_mode(0)
	var itens = get_node("Menu/Item/ScrollContainer/SubActions")
	for item in itens.get_children():
		item.hide()
	for i in range(inventory.size()):
		if inventory[i].quantity <= 0:
			itens.get_node(str(i)).set_focus_mode(0)
			itens.get_node(str(i)).disabled = true
		else:
			itens.get_node(str(i)).set_focus_mode(2)
			itens.get_node(str(i)).disabled = false
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(inventory[i].nome+" x"+str(inventory[i].quantity))
	
	get_node("Menu/Item")._on_Action_pressed()

func prepare_skills_action(skills: Array, current_mp: int) -> void:
	menu_state = "Skill"
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Item").hide()
	get_node("Menu/Run").hide()
	get_node("Menu/Skill").disabled = true
	get_node("Menu/Skill").set_focus_mode(0)
	var itens = get_node("Menu/Skill/ScrollContainer/SubActions")
	for item in itens.get_children():
		item.hide()

	for i in range(skills.size()):
		if current_mp < skills[i].quantity:
			itens.get_node(str(i)).set_focus_mode(0)
			itens.get_node(str(i)).disabled = true
		else:
			itens.get_node(str(i)).set_focus_mode(2)
			itens.get_node(str(i)).disabled = false
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(skills[i].nome+"  "+str(skills[i].quantity))
	
	get_node("Menu/Skill")._on_Action_pressed()

func prepare_attack_action() -> void:
	menu_state = "Attack"
	var unfocus = true
	get_node("Menu/Skill").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Item").hide()
	get_node("Menu/Run").hide()
	get_node("Menu/Attack").disabled = true
	get_node("Menu/Attack").set_focus_mode(0)
	var players = get_node("Menu/Attack/PlayerContainer")
	var enemies = get_node("Menu/Attack/EnemyContainer")
	for i in range(1,5):
		players.get_node(str(-i)).hide()
	for i in range(5):
		enemies.get_node(str(i)).hide()
	for i in range(1, Battle.Players.size() + 1):
		players.get_node(str(-i)).show()
		players.get_node(str(-i)).disabled = false
		players.get_node(str(-i)).set_text("")
	for i in range(Battle.Enemies.size()):
		if not Battle.Enemies[i].is_dead():
			if unfocus:
				enemies.get_node(str(i)).grab_focus()
				unfocus = false
			enemies.get_node(str(i)).show()
			enemies.get_node(str(i)).disabled = false
			enemies.get_node(str(i)).set_text("")
	enemies.get_node("0").grab_focus()
	get_node("Menu/Attack")._on_Action_pressed()
	get_node("Menu/Attack").set_pressed(true)
