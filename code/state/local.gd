extends Node

# State variables for the Demo_area
# TODO: make it not hardcoded and generic
var POSITION = Vector2(454, 446)
var STATE = {
	"1": {},
	"2": {},
	"3": {},
	"4": {},
	"5": {},
	"6": {},
	"7": {},
	"8": {},
	"9": {},
	"10": {},
	"11": {},
	"12": {},
	"13": {},
	"14": {},
	"15": {},
	"16": {},
	"17": {},
	"18": {},
	"19": {},
	"20": {},
	"21": {},
	"22": {},
	"23": {},
	"24": {},
	"25": {},
	"26": {}
}

# Global state variables
var AREA
var ENEMIES
var NPCs

var TRANSITION = -1
var MAP = 1
var WIN

var entering_battle = false
var IN_BATTLE = false

var events = {}
onready var loader = get_node("/root/LOADER")


# Returns state from the current map
func get_state():
	return STATE[MAP]


# Returns Enemies from current map
func load_enemies(filter_array):
	var enem = []
	ENEMIES = loader.load_enemies(filter_array)
	print("LOADEI INIMIGOS: ", ENEMIES)


# Return enemy with enemy_id (if loaded)
func get_enemy(enemy_id):
	for e in ENEMIES:
		if e.id == enemy_id:
			return e.duplicate()


# Return NPC with npc_id (if loaded)
func get_npc(npc_id):
	print("[LOCAL] getting npc with id ", npc_id)
	for npc in NPCs:
		print("NPC ", npc.id, " with name ", npc.nome)
		if npc.id == npc_id:
			print("[LOCAL] found it!")
			return npc


# Returns NPCs from current map
func load_npcs(filter_array):
	NPCs = loader.load_npcs(filter_array)


# Update state on the current map
func set_state(state_arg):
	STATE[MAP] = state_arg


func get_area():
	return AREA


func get_map():
	return MAP


func get_events():
	return events


# Resets state to the default Forest state
# TODO: make it generic
func load_initial_area():
	WIN = false
	AREA = "Forest"
	STATE = []
	events = {"rangers_defeated": false, "eyeballs_defeated": 0, "boss_defeated": false}
	for i in range(26):
		STATE.append({})
	TRANSITION = -1
	MAP = 1
	#MAP = 10
	POSITION = Vector2(454, 446)
	#POSITION = Vector2(300, 600)


# Joins all info from the map in a saveable format
func get_area_dict():
	var area_dict = {}
	area_dict["NAME"] = AREA
	area_dict["WIN"] = WIN
	area_dict["STATE"] = STATE
	area_dict["MAP"] = MAP
	area_dict["POSITION"] = POSITION
	return area_dict


# Loads map info from an area dictionary
func load_area(area_dict):
	WIN = area_dict["WIN"]
	STATE = area_dict["STATE"]
	MAP = area_dict["MAP"]
	POSITION = parse_position(area_dict["POSITION"])
	AREA = area_dict["NAME"]


# Helper function to parse a Vector2 from a string
func parse_position(pos_str):
	if typeof(pos_str) == TYPE_VECTOR2:
		return pos_str
	var x = pos_str.split(",")[0]
	x = x.substr(1, len(x))
	var y = pos_str.split(",")[1]
	y = y.substr(1, len(y) - 2)
	return Vector2(float(x), float(y))
