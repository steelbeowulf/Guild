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

# Shortcut variables
var cara_no_mundo = load("res://code/overworld/overworld_player.tscn")

# State variables
onready var enemie_on_map = []
onready var initial_player_position = Vector2(816, 368)
onready var state = {}


# Returns current maps' margins (used to limit player camera)
func get_map_margin():
	return [$Limits.margin_bottom, $Limits.margin_left, $Limits.margin_top, $Limits.margin_right]


###### PREPARATION FUNCTION #####


func _ready():
	# Initializes pause mode and play map music
	self.pause_mode = Node.PAUSE_MODE_STOP
	AUDIO.play_bgm("MAP_THEME", true)

	# Arbitrary stuff hardcoded for the demo
	# TODO: fix it

	#if GLOBAL.win:
	#	get_tree().change_scene("res://code/ui/victory.tscn")

	enemie_on_map = LOCAL.enemies
	initial_player_position = LOCAL.position

	# Gets current map state from global area state
	state = LOCAL.get_state()

	# Sets player position on map
	var pos = initial_player_position
	if LOCAL.position:
		pos = LOCAL.position
	if LOCAL.transition != -1:
		pos = Transitions[int(LOCAL.transition)]
		LOCAL.transition = -1
	var cara = cara_no_mundo.instance()
	$Party.add_child(cara)
	cara.position = pos
	LOCAL.position = pos
	cara.initialize()

	# Connects battle manager to monsters
	BATTLE_MANAGER.init(enemie_on_map, self)
	for e in get_node("enemie_on_map").get_children():
		e.connect("battle_notifier", BATTLE_MANAGER, "_encounter_management")

	# Updates objects and enemies on the map according to loaded state
	if state:
		for key in state.keys():
			var value = state[key]
			get_node(key).update_state(value)


# Updates player position and checks current map doors' conditions
# on each frame
# TODO: make check_doors be event driven
func _physics_process(_delta):
	LOCAL.position = $Party.get_child(0).get_global_position()
	#check_doors()


###### STATE FUNCTIONS #####


# Check if doors' objectives has been accomplished
# If so, opens it and sends a message on the HUD log
func check_doors():
	for d in Doors.keys():
		if Doors[d] == "Defeat all enemies" and not $enemie_on_map.get_children():
			get_node("Objects/" + str(d)).open()
			send_message("Uma nova passagem se abriu")
			Doors[d] = ""
		elif Doors[d] == "Matching puzzle" and LOCAL.match:
			get_node("Objects/" + str(d)).open()
			send_message("Uma nova passagem se abriu")
			Doors[d] = ""
		elif Doors[d].split(" ")[0] == "Activate":
			if get_node("Objects/" + str(Doors[d].split(" ")[1])).activated:
				get_node("Objects/" + str(d)).open()
				Doors[d] = ""
				send_message("Uma nova passagem se abriu")


# Updates all objects, player's and enemies states on the current map
func update_objects_position():
	for e in get_node("Objects").get_children():
		save_state("OBJ_POS", e.get_name(), e.open, e.get_global_position())
	for e in get_node("enemie_on_map").get_children():
		if e.dead:
			print("[MAP] Killing " + e.get_name())
			save_state("ENEMY_KILL", e.get_name())


# Saves a change on the current map
# The types of events currently available are:
# TREASURE -> when a treasure chest is opened
# ENEMY_KILL -> when a enemy is killed
# OBJ_POS -> when an object changes position
func save_state(type, node, open = false, pos = Vector2(0, 0)):
	if type == "TREASURE":
		state["Treasure/" + str(node)] = true
	elif type == "ENEMY_KILL":
		state["enemie_on_map/" + str(node)] = [true, pos]
	elif type == "OBJ_POS":
		state["Objects/" + str(node)] = [open, pos]
	# Saves current map state on the game's memory (not persistent)
	LOCAL.set_state(state)


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
