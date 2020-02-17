extends Node

var ALL_ITENS
var ALL_SKILLS
var ALL_ENEMIES
var ALL_PLAYERS
var INVENTORY
var POSITION = Vector2(816, 368)
var STATE = {'1':{}, '2':{}, '3':{}, '4':{}, '5':{}, 
			 '6':{}, '7':{}, '8':{}, '9':{}, '10':{},
			 '11':{}, '12':{}, '13':{}, '14':{}, '15':{}}
var TRANSITION
var MAP = 1
var WIN
onready var MATCH = false
onready var ROOM = false

func get_area_dict():
	var area_dict = {}
	area_dict["NAME"] = AREA
	area_dict["WIN"] = WIN
	area_dict["STATE"] = STATE
	area_dict["MATCH"] = MATCH
	area_dict["ROOM"] = ROOM
	area_dict["TRANSITION"] = TRANSITION
	area_dict["MAP"] = MAP
	area_dict["POSITION"] = POSITION
	return area_dict

func get_root():
	return find_node("Root")

func load_area(area_dict):
	WIN = area_dict["WIN"]
	STATE = area_dict["STATE"]
	MATCH = area_dict["MATCH"]
	ROOM = area_dict["ROOM"]
	TRANSITION = area_dict["TRANSITION"]
	MAP = area_dict["MAP"]
	POSITION = parse_position(area_dict["POSITION"])
	AREA = area_dict["NAME"]
	

func parse_position(pos_str):
	if typeof(pos_str) == TYPE_VECTOR2:
		return pos_str
	var x = pos_str.split(',')[0]
	x = x.substr(1, len(x))
	var y = pos_str.split(',')[1]
	y = y.substr(1, len(y)-2)
	

	return Vector2(float(x),float(y))

func reload_state():
	WIN = false
	STATE = {'1':{}, '2':{}, '3':{}, '4':{}, '5':{}, 
			 '6':{}, '7':{}, '8':{}, '9':{}, '10':{},
			 '11':{}, '12':{}, '13':{}, '14':{}, '15':{}}
	MATCH = false
	ROOM = false
	TRANSITION = null
	MAP = 1
	POSITION = Vector2(816, 368)

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

var savegame = File.new() 
var save_path = "./Save_data/Slot" 

func save_inventory(slot):
	var save_dict = []
	for item in INVENTORY:
		save_dict.append({"ID":item.id, "QUANT":item.quantity})
	savegame.open(save_path+str(slot)+"/Inventory.json", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()

func save(slot):
	var save_dict = {
		"area" : get_area_dict(),
        "gold" : get_gold(),
        "playtime" : get_playtime(),
}
	savegame.open(save_path+str(slot)+"/Info.json", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()
	var players_data = []
	for player in ALL_PLAYERS:
		players_data.append(player.save_data())
	savegame.open(save_path+str(slot)+"/Players.json", File.WRITE)
	savegame.store_line(to_json(players_data))
	savegame.close()
	return 0

func load_game(save_slot):
	savegame.open(save_path+str(save_slot)+"/Info.json", File.READ)
	var dict = parse_json(savegame.get_line())
	gold = dict["gold"]
	playtime = dict["playtime"]
	load_area(dict["area"])
	savegame.close()
	return 0

# Counts playtime

var AREA = "Demo_Area"
var gold = 100
var playtime = 0

func get_playtime():
	return playtime

func get_gold():
	return gold

func get_area():
	return AREA

func get_map():
	return MAP
