extends Node

# State variables for the Demo_area
# TODO: make it not hardcoded and generic
var POSITION = Vector2(454, 446)
var STATE = {'1':{}, '2':{}, '3':{}, '4':{}, '5':{}, 
	 '6':{}, '7':{}, '8':{}, '9':{}, '10':{},
	 '11':{}, '12':{}, '13':{}, '14':{}, '15':{},
	 '16':{}, '17':{}, '18':{}, '19':{}, '20':{},
	  '21':{}, '22':{}, '23':{}, '24':{}, '25':{}, '26':{}
}

# Global state variables
var AREA
var gold
var playtime
var ENEMIES_IN_AREA

var TRANSITION = -1
var MAP = 1
var WIN

var entering_battle = false
var IN_BATTLE = false


var events = {}

# Returns state from the current map
func get_state():
	return STATE[MAP]

# Returns Enemies from current map
#func get_enemies():
#	var enem = []
#	var filter_array = ENEMIES_IN_AREA[MAP]
#	for i in range(1, len(ENEMIES) -1):
#		var enemy = ENEMIES[i]
#		if enemy.id in filter_array:
#			enem.append(enemy)
#	return enem

# Update state on the current map
func set_state(state_arg):
	GLOBAL.STATE[GLOBAL.MAP] = state_arg

func get_area():
	return AREA

func get_map():
	return MAP

func get_events():
	return events

# Resets state to the default Demo_Area state
# TODO: make it generic
func reload_state():
	WIN = false
	STATE = []
	events = {
		"rangers_defeated": false, 
		"eyeballs_defeated": 0, 
		"boss_defeated": false
	}
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
	return area_dict["NAME"]


# Helper function to parse a Vector2 from a string
func parse_position(pos_str):
	if typeof(pos_str) == TYPE_VECTOR2:
		return pos_str
	var x = pos_str.split(',')[0]
	x = x.substr(1, len(x))
	var y = pos_str.split(',')[1]
	y = y.substr(1, len(y)-2)
	return Vector2(float(x),float(y))