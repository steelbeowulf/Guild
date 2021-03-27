extends Node
class_name LOADER

# Path to all persistent game data we're going to load
const ENEMY_PATH = "res://Data/Enemies/"
const ITENS_PATH = "res://Data/Itens/"
const EQUIPS_PATH = "res://Data/Equipaments/"
const SKILLS_PATH = "res://Data/Skills/"
const STATUS_PATH = "res://Data/Status/"
const AREAS_PATH = "res://Data/Maps/"
const NPCS_PATH = "res://Data/NPCs/"
const LORES_PATH = "res://Data/Lore/"
const ENCOUNTERS_PATH = "res://Data/NPCs/Encounters/"
const SHOPS_PATH = "res://Data/NPCs/Shops/"

# Path to load from on a new game (player data)
const PLAYERS_PATH = "res://Demo_data/Players.json"
const INVENTORY_PATH = "res://Demo_data/Inventory.json"
const EQUIPAMENT_PATH = "res://Demo_data/Equipament.json"

# Path where player data is saved on
const SAVE_PATH = "res://Save_data/"

# Some shortcuts for important classes we're going to use
var PLAYER_CLASS = load("res://Classes/Player.gd")
var ENEMY_CLASS = load("res://Classes/Enemy.gd")
var ITEM_CLASS = load("res://Classes/Itens.gd")
var EQUIP_CLASS = load("res://Classes/Equip.gd")
var NPC_CLASS = load("res://Classes/NPC.gd")
var ENCOUNTER_CLASS = load("res://Classes/Encounter.gd")
var SHOP_CLASS = load("res://Classes/Shop.gd")
var STATS_CLASS = load("res://Classes/StatEffect.gd")

var List

# Helper Function: returns a list of files on a directory
# pointed by the path argument
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files


func load_area_info(name):
	var file = File.new()		
	file.open(AREAS_PATH+name+".json", file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var data = result_json.result
		return data


# Returns a list with the Info.json dictionaries for each
# save slot - used to show saved info on the save slots
static func load_save_info():
	var ret = []
	var file = File.new()
	for i in range(4):
		file.open("res://Save_data/Slot"+str(i)+"/Info.json", file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			ret.append(data)
		else:
			ret.append({})
	return ret


# Loads all enemies found in the ENEMY_PATH directory.
func load_enemies(filter_array):
	var ret = []
	var enemies = list_files_in_directory(ENEMY_PATH)
	enemies.sort()
	
	for e in enemies:
		var file = File.new()
		file.open(ENEMY_PATH+e, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			if int(data["ID"]) in filter_array:
				var skills = []
				for id in data["SKILLS"]:
					skills.append(GLOBAL.SKILLS[id])
				ret.append(ENEMY_CLASS.new(data["ID"], data["LEVEL"], data["EXPERIENCE"], 
				data["IMG"], data["ANIM"],
				[data["HP"], data["HP_MAX"], 
				data["MP"], data["MP_MAX"],
				data["ATK"], data["ATKM"], 
				data["DEF"], data["DEFM"], 
				data["AGI"], data["ACC"], data["EVA"], data["LCK"]],
				data["NAME"], skills, data["RESISTANCE"]))
	return [0] + ret


# Loads all itens found in the ITENS_PATH directory.
# TODO: eventually will be changed to loading only itens
# that are in inventory/area chests, to not kill a PC's memory
func load_all_itens():
	var ret = []
	var itens = list_files_in_directory(ITENS_PATH)
	itens.sort()
	
	for i in itens:
		var file = File.new()
		file.open(ITENS_PATH+i, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			var effects = []
			for ef in data["EFFECTS"]:
				effects.append([STATS.DSTAT[ef["STAT"]], int(ef["VALUE"]), 
				STATS.TYPE[ef["TYPE"]], int(ef["TURNS"])]) 
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], STATS.DSTATUS[st["STATUS"]]])
			ret.append(ITEM_CLASS.new(data["ID"], data["NAME"], data["QUANT"], data["TARGET"],
				data["TYPE"], effects, status, data["IMG"], data["ANIM"]))

	return [0] + ret
	

# Loads all equipament found in the ITENS_PATH directory.
# TODO: eventually will be changed to loading only itens
# that are in inventory/area chests, to not kill a PC's memory
# Cloned from the item loaded
func load_all_equips():
	var ret = []
	var equips = list_files_in_directory(EQUIPS_PATH)
	equips.sort()
	for i in equips:
		var file = File.new()
		file.open(EQUIPS_PATH+i, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			var effects = []
			for ef in data["EFFECTS"]:
				var eff = STATS_CLASS.new(STATS.DSTAT[ef["STAT"]], ef["STAT"], int(ef["VALUE"]), ef["TYPE"])
				effects.append(eff) 
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], STATS.DSTATUS[st["STATUS"]]])
			ret.append(EQUIP_CLASS.new(data["ID"], data["NAME"],
				data["TYPE"], data["LOCATION"], data["CLASS"], effects, status, data["PRICE"], data["IMG"]))

	return [0] + ret




# Loads all skills found in the SKILLS_PATH directory.
# TODO: eventually will be changed to loading only skills
# from player characters/enemies in the area, to not kill a PC's memory
func load_all_skills():
	var ret = []
	var itens = list_files_in_directory(SKILLS_PATH)
	itens.sort()

	for s in itens:
		var file = File.new()
		
		file.open(SKILLS_PATH+s, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:  # If parse OK
			var data = result_json.result
			var effects = []
			for ef in data["EFFECTS"]:
				effects.append([STATS.DSTAT[ef["STAT"]], int(ef["VALUE"]), 
				STATS.TYPE[ef["TYPE"]], int(ef["TURNS"])]) 
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], STATS.DSTATUS[st["STATUS"]]])
			ret.append(ITEM_CLASS.new(data["ID"], data["NAME"], data["QUANT"], data["TARGET"],
				data["TYPE"], effects, status, data["IMG"], data["ANIM"]))

	return [0] + ret


# Loads all skills found in the SKILLS_PATH directory.
# TODO: eventually will be changed to loading only skills
# from player characters/enemies in the area, to not kill a PC's memory
func load_all_statuses():
	var ret = {}
	var statuses = list_files_in_directory(STATUS_PATH)
	statuses.sort()

	for s in statuses:
		var file = File.new()
		
		file.open(STATUS_PATH+s, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:  # If parse OK
			var data = result_json.result
			ret[data["NAME"]] = [data["AURA"]["COLOR"], data["AURA"]["THICKNESS"]]
		else:  # If parse has errors
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)

	print(ret)
	return ret


# Loads information regarding the players' inventory.
# If it's a new game, loads it from Demo_Data.
func load_inventory(slot):
	var path = INVENTORY_PATH
	if slot >= 0:
		path = SAVE_PATH+"Slot"+str(slot)+"/Inventory.json"
	return parse_inventory(path)

func load_equip(slot):
	var path = EQUIPAMENT_PATH
	print("LOADING EQUIPS", path)
	if slot >= 0:
		path = SAVE_PATH+"Slot"+str(slot)+"/Equipament.json"
	return parse_equipaments(path)


# Uses information from load_inventory to build the actual inventory,
# TODO: Fix dependency on load_all_itens when it doesn't load everything.
func parse_inventory(path):
	var file = File.new()
	file.open(path, file.READ)
	var itens = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var data = result_json.result
		for item in data:
			var item_copy = GLOBAL.ITENS[item["ID"]]._duplicate()
			itens.append(item_copy)
			item_copy.quantity = item["QUANT"]
	return itens



#THIS MIGHT BE INCORRECT, BUT WILL BE FIXED LATER - Z
func parse_equipaments(path):
	print("PARSING EQUIP ", path)
	var file = File.new()
	file.open(path, file.READ)
	var equips = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var data = result_json.result
		for equip in data:
			var equip_copy = GLOBAL.EQUIPAMENT[equip["ID"]]._duplicate()
			equips.append(equip_copy)
			equip_copy.quantity = equip["QUANT"]
	return equips


# Loads information regarding the players' characters.
# If it's a new game, loads it from Demo_Data.
func load_players(slot):
	var path = PLAYERS_PATH
	if slot >= 0:
		path = SAVE_PATH+"Slot"+str(slot)+"/Players.json"
	return parse_players(path)

func load_npcs(filter_array):
	print(filter_array)
	var npcs = list_files_in_directory(NPCS_PATH)
	npcs.sort()
	var ret = []
	for npc in npcs:
		print(npc)
		var file = File.new()
		file.open(NPCS_PATH+npc, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK: 
			var data = result_json.result
			if int(data["ID"]) in filter_array:
				ret.append(NPC_CLASS.new(data["ID"], data["NAME"],
				data["IMG"], data["ANIM"], data["DIALOGUE"], data["PORTRAIT"]))
		else:  # If parse has errors
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)

	return ret

func load_encounters(filter_array):
	print(filter_array)
	print("LOADING ENCOUNTERS")
	var encounters = list_files_in_directory(ENCOUNTERS_PATH)
	encounters.sort()
	var ret = []
	for encounter in encounters:
		print(encounter)
		var file = File.new()
		file.open(ENCOUNTERS_PATH+encounter, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK: 
			var data = result_json.result
			if int(data["ID"]) in filter_array:
				ret.append(ENCOUNTER_CLASS.new(data["ID"], data["NAME"],
				data["DIALOGUE"]))
		else:  # If parse has errors
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)

	return ret

func load_shops(filter_array):
	print(filter_array)
	print("LOADING SHOPS")
	var shops = list_files_in_directory(SHOPS_PATH)
	shops.sort()
	var ret = []
	for shop in shops:
		print(shop)
		var file = File.new()
		file.open(SHOPS_PATH+shop, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK: 
			var data = result_json.result
			if int(data["ID"]) in filter_array:
				ret.append(SHOP_CLASS.new(data["ID"], data["NAME"], 
					data["IMG"], data["ANIM"], 
					data["DIALOGUE"], data["PORTRAIT"], 
					data["ITENS"], data["EQUIPAMENTS"]))
		else:  # If parse has errors
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)

	return ret

# Uses information from load_players to build the actual players.
# TODO: Fix dependency on load_all_skills when it doesn't load everything.
func parse_players(path):
	var file = File.new()
	file.open(path, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  
		var datas = result_json.result
		for data in datas:
			var skills = []
			var equips = []
			for id in data["SKILLS"]:
				skills.append(GLOBAL.SKILLS[id])
			for id in data["EQUIPS"]:
				if id > -1:
					equips.append(GLOBAL.EQUIPAMENT[id])
				else:
					equips.append(null)
			players.append(PLAYER_CLASS.new(data["ID"], data["LEVEL"], 
			data["EXPERIENCE"], data["IMG"], data["PORTRAIT"], data["ANIM"],
			[data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["EVA"], data["LCK"]],
			data["LANE"], data["NAME"], skills, equips, data["RESISTANCE"], data["CLASS"]))
			for i in range(len(equips)):
				if data["EQUIPS"][i] > -1:
					players[-1].equip(i, equips[i])
	return players


func get_random_lore():
	var lores = list_files_in_directory(LORES_PATH)
	lores.shuffle()
	var file = File.new()
	file.open(LORES_PATH+lores[0], file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		return result_json.result
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
