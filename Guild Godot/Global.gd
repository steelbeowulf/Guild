extends Node

var ALL_ITENS
var ALL_SKILLS
var ALL_ENEMIES
var ALL_PLAYERS
var INVENTORY
var POSITION = Vector2(816, 368)
var STATE = {1:{}, 2:{}, 3:{}, 4:{}, 5:{}, 6:{}, 7:{}, 8:{}, 9:{}, 10:{},
	11:{}, 12:{}, 13:{}, 14:{}, 15:{}}
var TRANSITION
var MAP = 1
var WIN
onready var MATCH = false
onready var ROOM = false

func reload_state():
	WIN = false
	STATE = {1:{}, 2:{}, 3:{}, 4:{}, 5:{}, 6:{}, 7:{}, 8:{}, 9:{}, 10:{},
	11:{}, 12:{}, 13:{}, 14:{}, 15:{}}
	MATCH = false
	ROOM = false
	TRANSITION = null
	MAP = 1
	POSITION = null

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
	savegame.open(save_path+str(slot)+"/Inventory", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()

func save(slot):
	print("salvando saporra")
	var save_dict = {
		"area" : get_area(),
        "gold" : get_gold(),
        "playtime" : get_playtime(),
}
	savegame.open(save_path+str(slot)+"/Info", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()

func load_game(save_slot):
	if not savegame.file_exists(save_path+str(save_slot)):
		return -1
	savegame.open(save_path+str(save_slot)+"/Info", File.READ)
	var dict = parse_json(savegame.get_line())
	gold = dict["gold"]
	playtime = dict["playtime"]
	area = dict["area"]
	MAP = dict["map"]
	savegame.close()
	return 0

# Counts playtime

var area = "Demo_Area"
var gold = 100
var playtime = 0

func get_playtime():
	return playtime

func get_gold():
	return gold

func get_area():
	return area

func get_map():
	return MAP
