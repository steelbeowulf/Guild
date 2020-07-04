extends Node2D

# Positions for map transitions
# key: from which map I came
# value: position I start
export var Transitions = {}

# Doors and conditions
# key: node name
# value: condition
export var Doors = {}

export var Battle_BG = 1

# State variables
onready var Enemies = []
onready var Player_pos = Vector2(816, 368)
onready var state = {}

# Shortcut variables
var menu = load("res://Menu.tscn")
var cara_no_mundo = load("res://Overworld/Objects/Cara_no_mundo.tscn")


# Returns current maps' margins (used to limit player camera)
func get_map_margin():
	return [$Limits.margin_bottom, $Limits.margin_left,
	$Limits.margin_top, $Limits.margin_right]


###### PREPARATION FUNCTION #####

func _ready():
	# Initializes pause mode and play map music
	self.pause_mode = Node.PAUSE_MODE_STOP
	AUDIO.play_bgm('MAP_THEME', true)
	
	# Arbitrary stuff hardcoded for the demo
	# TODO: fix it
	if GLOBAL.get_map() == 4:
		get_node("Matching Puzzle").reset()
	if GLOBAL.WIN:
		get_tree().change_scene("res://Menu/Victory.tscn")
	
	# TODO: Limit Enemies to enemies on this area
	Enemies = GLOBAL.ENEMIES
	Player_pos = GLOBAL.POSITION
	
	# Gets current map state from global area state
	state = GLOBAL.get_state()

	# Sets player position on map
	var pos = Player_pos
	if GLOBAL.POSITION:
		pos = GLOBAL.POSITION
	if GLOBAL.TRANSITION != -1:
		pos = Transitions[int(GLOBAL.TRANSITION)]
		GLOBAL.TRANSITION = -1
	var cara = cara_no_mundo.instance()
	$Party.add_child(cara)
	cara.position = pos
	GLOBAL.POSITION = pos
	cara._initialize()
	
	# Connects battle manager to monsters
	var BM = get_node("/root/BATTLE_MANAGER")
	BM.init(Enemies, self)
	for e in get_node("Enemies").get_children():
		e.connect("battle_notifier", BM, "_encounter_management")

	# Updates objects and enemies on the map according to loaded state
	if state:
		for key in state.keys():
			var value = state[key]
			get_node(key)._update(value)


# Updates player position and checks current map doors' conditions
# on each frame
# TODO: make check_doors be event driven
func _physics_process(delta):
	GLOBAL.POSITION = $Party.get_child(0).get_global_position()
	check_doors()


###### STATE FUNCTIONS #####

# Check if doors' objectives has been accomplished
# If so, opens it and sends a message on the HUD log
func check_doors():
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


# Updates all objects, player's and enemies states on the current map
func update_objects_position():
	for e in get_node("Objects").get_children():
		save_state("OBJ_POS", e.get_name(), e.open, e.get_global_position())
	for e in get_node("Enemies").get_children():
		if e.dead:
			save_state("ENEMY_KILL", e.get_name())


# Saves a change on the current map
# The types of events currently available are:
# TREASURE -> when a treasure chest is opened
# ENEMY_KILL -> when a enemy is killed
# OBJ_POS -> when an object changes position
func save_state(type, node, open=false, pos=Vector2(0,0)):
	if type == "TREASURE":
		state["Treasure/"+str(node)] = true
	elif type == "ENEMY_KILL":
		state["Enemies/"+str(node)] = [true, pos]
	elif type == "OBJ_POS":
		state["Objects/"+str(node)] = [open, pos]
	# Saves current map state on the game's memory (not persistent)
	GLOBAL.set_state(state)


###### HUD FUNCTIONS #####

# Shows a message on the HUD log
func send_message(text):
	$HUD/Log.display_text(text)

# Hides the HUD layer (currently only a log)
func hide_hud():
	self.get_node("HUD").layer = -1


# Shows the HUD layer (currently only a log)
func show_hud():
	self.get_node("HUD").layer = 1
