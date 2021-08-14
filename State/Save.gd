extends Node

onready var loader = get_node("/root/LOADER")

# Save file variables
var savegame = File.new() 
var save_path = "./Save_data/Slot" 

# Loads all information from save_slot argument
func load_info(save_slot):
	if save_slot == -1:
		LOCAL.load_initial_area()
		return {
			"Gold": 100,
			"Playtime": 0,
			"Area": "Forest"
		}
	else:
		savegame.open(save_path+str(save_slot)+"/Info.json", File.READ)
		var dict = parse_json(savegame.get_line())
		savegame.close()
		LOCAL.load_area(dict["area"])
		return {
			"Gold": dict["gold"],
			"Playtime": dict["playtime"],
			"Area": dict["area"]["NAME"]
		}

# Load game saved on save_slot
func load_game(save_slot):
	var info = load_info(save_slot)
	var area_info = loader.load_area_info(info["Area"])
	return {
		"Inventory": loader.load_inventory(save_slot),
		"Equip_Inventory": loader.load_equip(save_slot),
		"Players": loader.load_players(save_slot),
		"Area_Info": info,
		"Enemies_in_area": area_info["ENEMIES"],
		"NPCs_in_area": area_info["NPCS"],
		"Reserve_Players": loader.load_reserve_players(save_slot),
		"Flags": loader.load_flags(save_slot)
	}

# Saves all information on the argument slot
func save(slot):
	# Saves the map information
	var save_dict = {
		"area" : LOCAL.get_area_dict(),
		"gold" : GLOBAL.get_gold(),
		"playtime" : GLOBAL.get_playtime(),
		"events" : LOCAL.get_events()
	}
	savegame.open(save_path+str(slot)+"/Info.json", File.WRITE)
	savegame.store_line(to_json(save_dict))
	savegame.close()

	# Saves players' information
	var players_data = []
	for player in GLOBAL.PLAYERS:
		players_data.append(player.save_data())
	savegame.open(save_path+str(slot)+"/Players.json", File.WRITE)
	savegame.store_line(to_json(players_data))
	savegame.close()

	# Saves inventory information
	var itens_data = []
	for item in GLOBAL.INVENTORY:
		itens_data.append({"ID":item.id, "QUANT":item.quantity})
	savegame.open(save_path+str(slot)+"/Inventory.json", File.WRITE)
	savegame.store_line(to_json(itens_data))
	savegame.close()

	# Saves equip inventory information
	var equip_data = []
	for item in GLOBAL.INVENTORY:
		equip_data.append({"ID":item.id, "QUANT":item.quantity})
	savegame.open(save_path+str(slot)+"/Equipament.json", File.WRITE)
	savegame.store_line(to_json(equip_data))
	savegame.close()