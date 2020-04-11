extends Node

# Global variables containing all loaded itens, skills and enemies
var ALL_ITENS
var ALL_SKILLS
var ALL_ENEMIES
var ALL_NPCS

# Global variables containing current players info (party and inventory)
var ALL_PLAYERS
var INVENTORY

var NODES = {}

var entering_battle = false

# State variables for the Demo_area
# TODO: make it not hardcoded and generic
var POSITION = Vector2(816, 368)
var STATE = {'1':{}, '2':{}, '3':{}, '4':{}, '5':{}, 
			 '6':{}, '7':{}, '8':{}, '9':{}, '10':{},
			 '11':{}, '12':{}, '13':{}, '14':{}, '15':{}}
var TRANSITION = -1
var MAP = 1
var WIN
onready var MATCH = false
onready var ROOM = false


# Helper function to get the Root node
func get_root():
	return get_node("/root/Root")


# Joins all info from the map in a saveable format
func get_area_dict():
	var area_dict = {}
	area_dict["NAME"] = AREA
	area_dict["WIN"] = WIN
	area_dict["STATE"] = STATE
	area_dict["MATCH"] = MATCH
	area_dict["ROOM"] = ROOM
	area_dict["MAP"] = MAP
	area_dict["POSITION"] = POSITION
	return area_dict


# Loads map info from an area dictionary
func load_area(area_dict):
	WIN = area_dict["WIN"]
	STATE = area_dict["STATE"]
	MATCH = area_dict["MATCH"]
	ROOM = area_dict["ROOM"]
	MAP = area_dict["MAP"]
	POSITION = parse_position(area_dict["POSITION"])
	AREA = area_dict["NAME"]


# Helper function to parse a Vector2 from a string
func parse_position(pos_str):
	if typeof(pos_str) == TYPE_VECTOR2:
		return pos_str
	var x = pos_str.split(',')[0]
	x = x.substr(1, len(x))
	var y = pos_str.split(',')[1]
	y = y.substr(1, len(y)-2)
	return Vector2(float(x),float(y))


# Resets state to the default Demo_Area state
# TODO: make it generic
func reload_state():
	WIN = false
	STATE = {'1':{}, '2':{}, '3':{}, '4':{}, '5':{}, 
			 '6':{}, '7':{}, '8':{}, '9':{}, '10':{},
			 '11':{}, '12':{}, '13':{}, '14':{}, '15':{}}
	MATCH = false
	ROOM = false
	TRANSITION = -1
	MAP = 1
	POSITION = Vector2(816, 368)


# Adds the item with item_id to the inventory, with quantity of item_quantity
func add_item(item_id, item_quantity):
	var done = false
	for item in INVENTORY:
		if item == ALL_ITENS[item_id]:
			item.quantity += item_quantity
			done = true
			break
	if not done:
		var item = ALL_ITENS[item_id]
		item.quantity += item_quantity
		INVENTORY.append(item)


# Save file variables
var savegame = File.new() 
var save_path = "./Save_data/Slot" 


# Saves all information on the argument slot
func save(slot):
	# Saves the map information
	var save_dict = {
		"area" : get_area_dict(),
        "gold" : get_gold(),
        "playtime" : get_playtime(),
	}
	savegame.open(save_path+str(slot)+"/Info.json", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()
	
	# Saves players' information
	var players_data = []
	for player in ALL_PLAYERS:
		players_data.append(player.save_data())
	savegame.open(save_path+str(slot)+"/Players.json", File.WRITE)
	savegame.store_line(to_json(players_data))
	savegame.close()
	
	# Saves inventory information
	var itens_data = []
	for item in INVENTORY:
		itens_data.append({"ID":item.id, "QUANT":item.quantity})
	savegame.open(save_path+str(slot)+"/Inventory.json", File.WRITE)
	savegame.store_line(to_json(itens_data))
	savegame.close()


# Loads all information from save_slot argument
func load_game(save_slot):
	savegame.open(save_path+str(save_slot)+"/Info.json", File.READ)
	var dict = parse_json(savegame.get_line())
	gold = dict["gold"]
	playtime = dict["playtime"]
	load_area(dict["area"])
	savegame.close()


# Global state variables
var AREA = "Demo_Area"
var gold = 100
var playtime = 0

# Returns state from the current map
func get_state():
	return STATE[str(MAP)]

# Update state on the current map
func set_state(state_arg):
	GLOBAL.STATE[GLOBAL.MAP] = state_arg

func get_playtime():
	return playtime

func get_gold():
	return gold

func get_area():
	return AREA

func get_map():
	return MAP

func register_node(name, node):
	NODES[name] = node

var caller = null

func play_dialogues(id, callback):
	print(ALL_NPCS)
	var node = NODES["Dialogue"]
	var dials = ALL_NPCS[id].get_dialogues()
	for dial in dials:
		node.push_dialogue(dial)
	caller = callback
	node.start_dialogue()

func dialogue_ended():
	caller._on_Dialogue_Ended()