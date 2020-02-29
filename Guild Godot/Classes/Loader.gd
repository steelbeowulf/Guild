extends Node
class_name LOADER

# Path to all persistent game data we're going to load
const ENEMY_PATH = "res://Data/Enemies/"
const ITENS_PATH = "res://Data/Itens/"
const SKILLS_PATH = "res://Data/Skills/"

# Path to load from on a new game (player data)
const PLAYERS_PATH = "res://Demo_data/Players.json"
const INVENTORY_PATH = "res://Demo_data/Inventory.json"

# Path where player data is saved on
const SAVE_PATH = "res://Save_data/"

# Some shortcuts for important classes we're going to use
var PLAYER_CLASS = load("res://Classes/Player.gd")
var ENEMY_CLASS = load("res://Classes/Enemy.gd")
var ITEM_CLASS = load("res://Classes/Itens.gd")

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
# TODO: eventually will be changed to loading only enemies
# necessary for a certain area, to not kill a PC's memory
func load_all_enemies():
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
			var skills = []
			for id in data["SKILLS"]:
				skills.append(GLOBAL.ALL_SKILLS[id])
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
				data["TYPE"], effects, status))

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
				data["TYPE"], effects, status))

	return [0] + ret


# Loads information regarding the players' inventory.
# If it's a new game, loads it from Demo_Data.
func load_inventory(slot):
	var path = INVENTORY_PATH
	if slot >= 0:
		path = SAVE_PATH+"Slot"+str(slot)+"/Inventory.json"
	return parse_inventory(path)

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
			itens.append(GLOBAL.ALL_ITENS[item["ID"]])
			itens[-1].quantity = item["QUANT"]
	return itens


# Loads information regarding the players' characters.
# If it's a new game, loads it from Demo_Data.
func load_players(slot):
	var path = PLAYERS_PATH
	if slot >= 0:
		path = SAVE_PATH+"Slot"+str(slot)+"/Players.json"
	return parse_players(path)


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
			for id in data["SKILLS"]:
				skills.append(GLOBAL.ALL_SKILLS[id])
			players.append(PLAYER_CLASS.new(data["ID"], data["LEVEL"], 
			data["EXPERIENCE"], data["IMG"], data["ANIM"],
			[data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["EVA"], data["LCK"]],
			data["LANE"], data["NAME"], skills, data["RESISTANCE"]))
	return players