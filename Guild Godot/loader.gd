extends Node
class_name LOADER

static func players_from_file(path):
	var cenaplayer = preload("res://Player.gd")
	var file = File.new()
	file.open(path, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:  # If parse OK
		var datas = result_json.result
		for data in datas:
			players.append(cenaplayer.new([data["ATK"], data["ATKM"], 
			data["DEF"], data["DEFM"], 
			data["AGI"], data["LCK"]],
			data["HEALTH"], data["LANE"], data["NAME"]))
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	return players