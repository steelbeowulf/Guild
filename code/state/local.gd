extends Node

# State variables for the Demo_area
# TODO: make it not hardcoded and generic
var position = Vector2(454, 446)
var state = {
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
var area
var enemies
var npcs

var transition = -1
var map = 1
var win

var entering_battle = false
var in_battle = false

var events = {}
onready var loader = get_node("/root/LOADER")


# Returns state from the current map
func get_state():
	return state[map]


# Returns Enemies from current map
func load_enemies(filter_array):
	var enem = []
	enemies = loader.load_enemies(filter_array)
	print("LOADEI INIMIGOS: ", enemies)


# Return enemy with enemy_id (if loaded)
func get_enemy(enemy_id):
	for e in enemies:
		if e.id == enemy_id:
			return e.clone()


# Return NPC with npc_id (if loaded)
func get_npc(npc_id):
	print("[LOCAL] getting npc with id ", npc_id)
	for npc in npcs:
		print("NPC ", npc.id, " with name ", npc.name)
		if npc.id == npc_id:
			print("[LOCAL] found it!")
			return npc


# Returns npcs from current map
func load_npcs(filter_array):
	npcs = loader.load_npcs(filter_array)


# Update state on the current map
func set_state(state_arg):
	state[map] = state_arg


func get_area():
	return area


func get_map():
	return map


func get_events():
	return events


# Resets state to the default Forest state
# TODO: make it generic
func load_initial_area():
	win = false
	area = "Forest"
	state = []
	events = {"rangers_defeated": false, "eyeballs_defeated": 0, "boss_defeated": false}
	for i in range(26):
		state.append({})
	transition = -1
	map = 1
	#map = 10
	position = Vector2(454, 446)
	#position = Vector2(300, 600)


# Joins all info from the map in a saveable format
func get_area_dict():
	var area_dict = {}
	area_dict["NAME"] = area
	area_dict["win"] = win
	area_dict["state"] = state
	area_dict["map"] = map
	area_dict["position"] = position
	return area_dict


# Loads map info from an area dictionary
func load_area(area_dict):
	win = area_dict["win"]
	state = area_dict["state"]
	map = area_dict["map"]
	position = parse_position(area_dict["position"])
	area = area_dict["NAME"]


# Helper function to parse a Vector2 from a string
func parse_position(pos_str):
	if typeof(pos_str) == TYPE_VECTOR2:
		return pos_str
	var x = pos_str.split(",")[0]
	x = x.substr(1, len(x))
	var y = pos_str.split(",")[1]
	y = y.substr(1, len(y) - 2)
	return Vector2(float(x), float(y))
