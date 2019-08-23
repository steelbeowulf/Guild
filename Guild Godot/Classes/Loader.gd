extends Node
class_name LOADER

const ENEMY_PATH = "res://Data/Enemies/"
const ITENS_PATH = "res://Data/Itens/"
const SKILLS_PATH = "res://Data/Skills/"
const PLAYERS_PATH = "res://Testes/Players.json"
const INVENTORY_PATH = "res://Testes/Inventory.json"

var PLAYER_CLASS = load("res://Classes/Player.gd")
var ENEMY_CLASS = load("res://Classes/Enemy.gd")
var ITEM_CLASS = load("res://Classes/Itens.gd")

var List = []

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

func load_all_enemies():
	print("vou carregar inimigos")
	var ret = []
	var enemies = list_files_in_directory(ENEMY_PATH)
	enemies.sort()
	print(enemies)
	for e in enemies:
		var file = File.new()
		file.open(ENEMY_PATH+e, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:  # If parse OK
			var data = result_json.result
			var skills = []
			for id in data["SKILLS"]:
				skills.append(GLOBAL.ALL_SKILLS[id])
			ret.append(ENEMY_CLASS.new(data["ID"], data["LEVEL"], data["EXPERIENCE"], data["IMG"],
			[data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["LCK"]],
			data["NAME"], skills, data["RESISTANCE"]))
		else:  # If parse has errors
			print(e)
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)
	return [0] + ret

func load_all_itens():
	print("vou carregar itens")
	var ret = []
	var itens = list_files_in_directory(ITENS_PATH)
	itens.sort()
	print(itens)
	for i in itens:
		print(i)
		var file = File.new()
		file.open(ITENS_PATH+i, file.READ)
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
			ret.append(ITEM_CLASS.new(data["NAME"], data["QUANT"], data["TARGET"],
				data["TYPE"], effects, status))
		else:  # If parse has errors
			print(i)
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)
	return [0] + ret

func load_all_skills():
	print("vou carregar skills")
	var ret = []
	var itens = list_files_in_directory(SKILLS_PATH)
	itens.sort()
	print(itens)
	for s in itens:
		var file = File.new()
		print(s)
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
			ret.append(ITEM_CLASS.new(data["NAME"], data["QUANT"], data["TARGET"],
				data["TYPE"], effects, status))
		else:  # If parse has errors
			print(s)
			print("Error: ", result_json.error)
			print("Error Line: ", result_json.error_line)
			print("Error String: ", result_json.error_string)
	return [0] + ret

func build_inventory():
	print("vou carregar inveotário")
	var file = File.new()
	file.open(INVENTORY_PATH, file.READ)
	var itens = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var data = result_json.result
		for item in data:
			itens.append(GLOBAL.ALL_ITENS[item["ID"]])
			itens[-1].quantity = item["QUANT"]
	else:  # If parse has errors
		print('inve')
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return itens

func players_from_file():
	print("vou carregar players")
	var file = File.new()
	file.open(PLAYERS_PATH, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var datas = result_json.result
		for data in datas:
			var skills = []
			for id in data["SKILLS"]:
				skills.append(GLOBAL.ALL_SKILLS[id])
			players.append(PLAYER_CLASS.new(data["ID"], data["LEVEL"], 
			data["EXPERIENCE"], data["IMG"],
			[data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["LCK"]],
			data["LANE"], data["NAME"], skills, data["RESISTANCE"]))
	else:  # If parse has errors
		print('players')
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return players