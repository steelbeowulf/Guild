extends Node

# Global variables containing all loaded itens, skills and enemies
var ITENS
var SKILLS
var STATUS
var ENEMIES
var NPCS
var SHOPS
var ENCOUNTERS

# Global variables containing current players info (party and inventory)
var PLAYERS
var INVENTORY

var NODES = {}

var entering_battle = false
var IN_BATTLE = false

# State variables for the Demo_area
# TODO: make it not hardcoded and generic
var POSITION = Vector2(454, 446)
var STATE = {'1':{}, '2':{}, '3':{}, '4':{}, '5':{}, 
			 '6':{}, '7':{}, '8':{}, '9':{}, '10':{},
			 '11':{}, '12':{}, '13':{}, '14':{}, '15':{},
			 '16':{}, '17':{}, '18':{}, '19':{}, '20':{},
			  '21':{}, '22':{}, '23':{}, '24':{}, '25':{}, '26':{}}

var TRANSITION = -1
var MAP = 1
var WIN
onready var MATCH = false
onready var ROOM = false

# Loading stuff
var NEXT_SCENE = "res://Root.tscn"

# Helper function to get the Root node
func get_root():
	return get_node("/root/Root")


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

var events = {}

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


# Adds the item with item_id to the inventory, with quantity of item_quantity
func add_item(item_id, item_quantity):
	var done = false
	for item in INVENTORY:
		if item == ITENS[item_id]:
			item.quantity += item_quantity
			done = true
			break
	if not done:
		var item = ITENS[item_id]
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
		"events" : get_events()
	}
	savegame.open(save_path+str(slot)+"/Info.json", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()
	
	# Saves players' information
	var players_data = []
	for player in PLAYERS:
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

# Global state variables
var AREA
var gold
var playtime
var ENEMIES_IN_AREA

onready var loader = get_node("/root/LOADER")

# Loads all information from save_slot argument
func load_info(save_slot):
	if save_slot == -1:
		reload_state()
		gold = 100
		playtime = 0
		# TODO: Change this back
		#AREA = "Demo_Area"
		AREA = "Hub"
	else:
		savegame.open(save_path+str(save_slot)+"/Info.json", File.READ)
		var dict = parse_json(savegame.get_line())
		gold = dict["gold"]
		playtime = dict["playtime"]
		events = dict["events"]
		AREA = load_area(dict["area"])
		savegame.close()


func load_game(save_slot):
	STATUS = loader.load_all_statuses()
	SKILLS = loader.load_all_skills()
	ITENS = loader.load_all_itens()
	
	INVENTORY = loader.load_inventory(save_slot)
	PLAYERS = loader.load_players(save_slot)
	
	load_info(save_slot)
	var area_info = loader.load_area_info(AREA)
	ENEMIES_IN_AREA = area_info["ENEMIES_BY_AREA"]
	NPCS = loader.load_npcs(area_info["NPCS"])
	print(NPCS)

	ENCOUNTERS = loader.load_encounters(area_info["ENCOUNTERS"])
	print(ENCOUNTERS)
	
	SHOPS = loader.load_shops(area_info["SHOPS"])
	print(SHOPS)

	ENEMIES = loader.load_enemies(area_info["ENEMIES"])
	print(ENEMIES)

# Returns state from the current map
func get_state():
	return STATE[MAP]

# Returns Enemies from current map
func get_enemies():
	var enem = []
	var filter_array = ENEMIES_IN_AREA[MAP]
	for i in range(1, len(ENEMIES) -1):
		var enemy = ENEMIES[i]
		if enemy.id in filter_array:
			enem.append(enemy)
	return enem

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

func get_events():
	return events

func register_node(name, node):
	NODES[name] = node

### Events

func get_event_status(id):
	return events[id]

func set_event_status(id, status):
	events[id] = status

### Dialogue
var caller = null

func play_dialogues(id, callback, shop=false):
	var node = NODES["Dialogue"]
	var npc = null
	if shop:
		npc = SHOPS[id]
	else:
		npc = NPCS[id]
	var dials = npc.get_dialogues()
	node.set_talker(npc.get_name(), npc.get_portrait())
	for dial in dials:
		node.push_dialogue(dial)
	caller = callback
	node.start_dialogue()

func play_dialogue(dialogue, callback):
	var node = NODES["Dialogue"]
	node.set_talker(dialogue.name, dialogue.portrait)
	for dial in dialogue.message:
		node.push_dialogue(dial)
	caller = callback
	node.start_dialogue()

func dialogue_ended():
	caller._on_Dialogue_Ended()
