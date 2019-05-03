extends Node
class_name LOADER

var List = []

static func players_from_file(path):
	var cenaplayer = load("res://Classes/Player.gd")
	var file = File.new()
	file.open(path, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var datas = result_json.result
		for data in datas:
			players.append(cenaplayer.new([data["HP"], data["HP_MAX"], 
			data["MP"], data["MP_MAX"],
			data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["ACC"], data["LCK"]],
			data["LANE"], data["NAME"], []))
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
	var TYPE = {"":-1, "PHYSIC":0, "MAGIC":1}
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
			effects, status))
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return itens

