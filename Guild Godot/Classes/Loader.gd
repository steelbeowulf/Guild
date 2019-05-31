extends Node
class_name LOADER

var List = []
var STATUS = {0:"CONFUSION", 1:"POISON", 2:"BURN", 3:"SLOW", 
	4:"HASTE", 5:"BERSERK", 6:"REGEN", 7:"UNDEAD", 8:"PETRIFY", 9:"SILENCE", 
	10:"BLIND", 11:"DOOM", 12:"PARALYSIS", 13:"MAX_HP_DOWN", 14:"MAX_MP_DOWN", 
	15:"SLEEP", 16:"FLOAT", 17:"UNKILLABLE", 18:"VISIBILITY", 19:"REFLECT", 
	20:"CONTROL", 21:"CHARM", 22:"HP_CRITICAL", 23:"CURSE", 24:"STOP", 
	25:"HIDDEN", 26:"FREEZE", 27:"IMMOBILIZE", 28:"KO", 29:"VEIL", 30:"TRAPPED", 31:"ATTACK_UP",
	32:"ATTACK_DOWN", 33:"DEFENSE_UP", 34:"DEFENSE_DOWN", 35:"MAGIC_DEFENSE_UP", 37:"MAGIC_DEFENSE_DOWN",
	38:"MAGIC_ATTACK_UP", 39:"MAGIC_ATTACK_DOWN", 40:"MAX_HP_UP", 41:"MAX_MP_UP", 42:"ACCURACY_UP",
	43:"ACCURACY_DOWN", 44:"AGILITY_UP", 45:"AGILITY_DOWN", 46:"LUCK_UP", 47:"LUCK_DOWN", 48:"FEAR"}


static func enemies_from_file(path):
	var STATUS = {"":-1, "CONFUSION":0, "POISON":1, "BURN":2, "SLOW":3, 
	"HASTE":4, "BERSERK":5, "REGEN":6, "UNDEAD":7, "PETRIFY":8, "SILENCE":9, 
	"BLIND":10, "DOOM":11, "PARALYSIS":12, "MAX_HP_DOWN":13, "MAX_MP_DOWN":14, 
	"SLEEP":15, "FLOAT":16, "UNKILLABLE":17, "VISIBILITY":18, "REFLECT":19, 
	"CONTROL":20, "CHARM":21, "HP_CRITICAL":22, "CURSE":23, "STOP":24, 
	"HIDDEN":25, "FREEZE":26, "IMMOBILIZE":27, "KO":28, "VEIL":29, "TRAPPED":30}
	var TYPE = {"":-1, "PHYSIC":0, "MAGIC":1, "FIRE":2, "EARTH":3, "WIND":4}
	var STAT = {"HP":0, "HP_MAX":1, "MP":2, "MP_MAX":3, "ATK":4, "ATKM":5, "DEF":6, "DEFM":7, "AGI":8, "LCK":9}
	var cenaitem = load("res://Classes/Itens.gd")
	var cenaenemy = load("res://Classes/Enemy.gd")
	var file = File.new()
	file.open(path, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var datas = result_json.result
		for data in datas:
			var skills = []
			for sk in data["SKILLS"]:
				var effects = []
				for ef in sk["EFFECTS"]:
					effects.append([STAT[ef["STAT"]], int(ef["VALUE"]), 
					TYPE[ef["TYPE"]], int(ef["TURNS"])]) 
				#print(effects)
				var status = []
				for st in sk["STATUS"]:
					status.append([st["BOOL"], STATUS[st["STATUS"]]])
				skills.append(cenaitem.new(sk["NAME"], sk["QUANT"], sk["TARGET"],
				sk["TYPE"], effects, status))
			players.append(cenaenemy.new(data["ID"], data["LEVEL"], data["EXPERIENCE"], data["IMG"],
			[data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["LCK"]],
			data["NAME"], skills))
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return players

static func players_from_file(path):
	var STATUS = {"":-1, "CONFUSION":0, "POISON":1, "BURN":2, "SLOW":3, 
	"HASTE":4, "BERSERK":5, "REGEN":6, "UNDEAD":7, "PETRIFY":8, "SILENCE":9, 
	"BLIND":10, "DOOM":11, "PARALYSIS":12, "MAX_HP_DOWN":13, "MAX_MP_DOWN":14, 
	"SLEEP":15, "FLOAT":16, "UNKILLABLE":17, "VISIBILITY":18, "REFLECT":19, 
	"CONTROL":20, "CHARM":21, "HP_CRITICAL":22, "CURSE":23, "STOP":24, 
	"HIDDEN":25, "FREEZE":26, "IMMOBILIZE":27, "KO":28, "VEIL":29, "TRAPPED":30}
	var RESISTANCES = {"FIRE":0, "WATER":1, "ELECTRIC":2, "ICE":3, "EARTH":4, "WIND":5, "HOLY":6, "DARKNESS":7}
	var TYPE = {"":-1, "PHYSIC":0, "MAGIC":1}
	var STAT = {"HP":0, "HP_MAX":1, "MP":2, "MP_MAX":3, "ATK":4, "ATKM":5, "DEF":6, "DEFM":7, "AGI":8, "LCK":9}
	var cenaitem = load("res://Classes/Itens.gd")
	var cenaplayer = load("res://Classes/Player.gd")
	var file = File.new()
	file.open(path, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var datas = result_json.result
		for data in datas:
			var skills = []
			for sk in data["SKILLS"]:
				var effects = []
				for ef in sk["EFFECTS"]:
					effects.append([STAT[ef["STAT"]], int(ef["VALUE"]), 
					TYPE[ef["TYPE"]], int(ef["TURNS"])]) 
				#print(effects)
				var status = []
				for st in sk["STATUS"]:
					status.append([st["BOOL"], STATUS[st["STATUS"]]])
				skills.append(cenaitem.new(sk["NAME"], sk["QUANT"], sk["TARGET"],
				sk["TYPE"], effects, status))
			#var resist = []
			#for res in data["RESISTANCE"]:
				#resist.append(res)
			players.append(cenaplayer.new(data["LEVEL"], data["EXPERIENCE"],
			[data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["LCK"]],
			data["LANE"], data["NAME"], skills, data["RESISTANCE"]))
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return players

static func items_from_file(path):
	var STATUS = {"":-1, "CONFUSION":0, "POISON":1, "BURN":2, "SLOW":3, 
	"HASTE":4, "BERSERK":5, "REGEN":6, "UNDEAD":7, "PETRIFY":8, "SILENCE":9, 
	"BLIND":10, "DOOM":11, "PARALYSIS":12, "MAX_HP_DOWN":13, "MAX_MP_DOWN":14, 
	"SLEEP":15, "FLOAT":16, "UNKILLABLE":17, "VISIBILITY":18, "REFLECT":19, 
	"CONTROL":20, "CHARM":21, "HP_CRITICAL":22, "CURSE":23, "STOP":24, 
	"HIDDEN":25, "FREEZE":26, "IMMOBILIZE":27, "KO":28, "VEIL":29, "TRAPPED":30}
	var TYPE = {"":-1, "PHYSIC":0, "MAGIC":1, "FIRE":2}
	var STAT = {"HP":0, "HP_MAX":1, "MP":2, "MP_MAX":3, "ATK":4, "ATKM":5, "DEF":6, "DEFM":7, "AGI":8, "LCK":9}
	var cenaitem = load("res://Classes/Itens.gd")
	var file = File.new()
	file.open(path, file.READ)
	var itens = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var datas = result_json.result
		for data in datas:
			var effects = []
			for ef in data["EFFECTS"]:
				effects.append([STAT[ef["STAT"]], int(ef["VALUE"]), 
				TYPE[ef["TYPE"]], int(ef["TURNS"])]) 
			#print(effects)
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], STATUS[st["STATUS"]]])
			itens.append(cenaitem.new(data["NAME"], data["QUANT"], data["TARGET"],
			data["TYPE"], effects, status))
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return itens

