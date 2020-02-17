extends Node2D

export var Transitions = {}
export var Doors = {}

onready var Players = []
onready var Inventory = []
onready var Enemies = []
onready var Encounter = []
onready var Kill = []

var menu = load("res://Menu.tscn")
var cara_no_mundo = load("res://Overworld/Objects/Cara_no_mundo.tscn")
onready var Player_pos = Vector2(816, 368)
onready var state = {}
var id = 0


func generate_enemies():
	var newEnemy = []
	var total = int(rand_range(1,4))
	if Encounter and Encounter[0] == 9:
		total = 0
		GLOBAL.WIN = true
	var current = 0
	Encounter.shuffle()
	for k in Kill:
		get_node("Enemies/"+str(k)).dead = true
	while current <= total:
		if Encounter:
			newEnemy.append(Enemies[Encounter[0]]._duplicate())
			Encounter.pop_front()
		else:
			var enemy_id = int(rand_range(1,len(Enemies)-1))
			newEnemy.append(Enemies[enemy_id]._duplicate())
		current+=1
	BATTLE_INIT.begin_battle(id, newEnemy, Kill)
	return

# Called when the node enters the scene tree for the first time.
func _ready():

	self.pause_mode = Node.PAUSE_MODE_STOP
	AUDIO.play_bgm('MAP_THEME', true)
	if get_tree().get_current_scene().get_area() == 'Map4':
		get_node("Matching Puzzle").reset()
	if GLOBAL.WIN:
		get_tree().change_scene("res://Menu/Victory.tscn")
	Enemies = GLOBAL.ALL_ENEMIES
	Encounter = []
	var name = get_name()
	id = int(name.substr(3, len(name)))
	GLOBAL.MAP = id
	Player_pos = GLOBAL.POSITION
	if BATTLE_INIT.first:
		Players = GLOBAL.ALL_PLAYERS
		Inventory = GLOBAL.INVENTORY
		BATTLE_INIT.init(Players, Enemies)
	else:
		Players = BATTLE_INIT.Play
		if Players == []:
			get_tree().change_scene("res://Battle/Game Over.tscn")
	if GLOBAL.STATE[str(id)]:
		state = GLOBAL.STATE[str(id)]

	var pos = Player_pos
	if GLOBAL.POSITION:
		pos = GLOBAL.POSITION
	if GLOBAL.TRANSITION:
		pos = Transitions[GLOBAL.TRANSITION]
		GLOBAL.TRANSITION = false

	var cara = cara_no_mundo.instance()
	$Party.add_child(cara)
	#var cara = get_node("Party/Cara")
	# Connects itself to monsters
	for e in get_node("Enemies").get_children():
		e.connect("battle_notifier", self, "_encounter_management")

	if state:
		for key in state.keys():
			var value = state[key]
			get_node(key)._update(value)

	cara.position = pos
	GLOBAL.POSITION = pos
	cara._rready()

func _encounter_management(value, id, name):

	if value:
		Encounter.append(id)
		Kill.append(name)
	else:
		Encounter.erase(id)
		Kill.erase(name)

func get_map_margin():
	return [$Limits.margin_bottom, $Limits.margin_left,
	$Limits.margin_top, $Limits.margin_right]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var pos = $Party.get_child(0).get_global_position()
	GLOBAL.POSITION = pos
	for d in Doors.keys():
		if Doors[d] == 'Defeat all enemies' and not $Enemies.get_children():
			get_node("Objects/"+str(d)).open()
			send_message("Uma nova passagem se abriu")
			Doors[d] = ''
		elif Doors[d] == 'Matching puzzle' and GLOBAL.MATCH:
			get_node("Objects/"+str(d)).open()
			send_message("Uma nova passagem se abriu")
			Doors[d] = ''
		elif Doors[d].split(" ")[0] == 'Activate':
			if get_node("Objects/"+str(Doors[d].split(" ")[1])).activated:
				get_node("Objects/"+str(d)).open()
				Doors[d] = ''
				send_message("Uma nova passagem se abriu")

func send_message(text):
	$HUD/Log.display_text(text)

func update_objects_position():
	for e in get_node("Objects").get_children():
		save_state("OBJ_POS", e.get_name(), e.open, e.get_global_position())
	for p in get_node("Party").get_children():
		save_state("PLAYER_POS", p.get_name(), p.get_global_position())
	for e in get_node("Enemies").get_children():
		if e.dead:
			save_state("ENEMY_KILL", e.get_name())

func save_state(type, node, open=false, pos=Vector2(0,0)):
	if type == "TREASURE":
		state["Treasure/"+str(node)] = true
	elif type == "ENEMY_KILL":
		state["Enemies/"+str(node)] = [true, pos]
	elif type == "OBJ_POS":
		state["Objects/"+str(node)] = [open, pos]
	elif type == "PLAYER_POS":
		state["Party/"+str(node)] = [false, pos]
	GLOBAL.STATE[str(id)] = state

func hide_hud():
	self.get_node("HUD").layer = -1

func show_hud():
	self.get_node("HUD").layer = 1
