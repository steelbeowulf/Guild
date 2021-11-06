class_name LOADER
extends Node

# Path to all persistent game data we're going to load
const ENEMY_PATH = "res://data/game_data/Enemies/"
const ITENS_PATH = "res://data/game_data/Itens/"
const EQUIPS_PATH = "res://data/game_data/Equipments/"
const SKILLS_PATH = "res://data/game_data/Skills/"
const STATUS_PATH = "res://data/game_data/Status/"
const AREAS_PATH = "res://data/game_data/Maps/"
const NPCS_PATH = "res://data/game_data/NPCs/"
const LORES_PATH = "res://data/game_data/Lore/"
const ENCOUNTERS_PATH = "res://data/game_data/NPCs/Encounters/"
const SHOPS_PATH = "res://data/game_data/NPCs/Shops/"
const RESERVE_PLAYERS_PATH = "res://data/game_data/Seeds/Reserve Players.json"

# Path to load from on a new game (player data)
const PLAYERS_PATH = "res://data/game_data/Seeds/Players.json"
const INVENTORY_PATH = "res://data/game_data/Seeds/Inventory.json"
const EQUIPMENT_PATH = "res://data/game_data/Seeds/Equipment.json"
const JOBS_PATH = "res://data/game_data/Seeds/Jobs.json"
const FLAGS_PATH = "res://data/game_data/Seeds/Flags.json"

# Path where player data is saved on
const SAVE_PATH = "res://data/save_data/"

# Some shortcuts for important classes we're going to use
const PLAYER_CLASS = preload("res://code/classes/entities/player.gd")
const ENEMY_CLASS = preload("res://code/classes/entities/enemy.gd")
const ITEM_CLASS = preload("res://code/classes/objects/item.gd")
const EQUIP_CLASS = preload("res://code/classes/objects/equipment.gd")
const NPC_CLASS = preload("res://code/classes/entities/npc.gd")
const JOB_CLASS = preload("res://code/classes/objects/jobs.gd")

const SHOP_CLASS = preload("res://code/classes/events/shop.gd")
const STATS_CLASS = preload("res://code/classes/events/stat_effect.gd")
const STATUS_CLASS = preload("res://code/classes/events/status_effect.gd")
const DIALOGUE_CLASS = preload("res://code/classes/events/dialogue.gd")

const OPTION_CLASS = preload("res://code/classes/events/dialogue_option.gd")
const BATTLE_CLASS = preload("res://code/classes/events/battle.gd")
const TRANSITION_CLASS = preload("res://code/classes/events/transition.gd")
const FLAG_CLASS = preload("res://code/classes/events/flag.gd")
const REINFORCEMENT_CLASS = preload("res://code/classes/events/reinforcements.gd")
const SET_ACTION_CLASS = preload("res://code/classes/events/set_action.gd")
const SET_TARGET_CLASS = preload("res://code/classes/events/set_target.gd")

# Helper Function: returns a list of files on a directory
# defined by the path argument
func list_files_in_directory(path: String):
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

# Loads information for area area_name
func load_area_info(area_name: String):
	var file = File.new()
	file.open(AREAS_PATH + area_name + ".json", file.READ)
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
		file.open("res://data/save_data/slot" + str(i) + "/Info.json", file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			ret.append(data)
		else:
			ret.append({})
	return ret

# Returns a list with the Info.json dictionaries for each
# save slot - used to show saved info on the save slots
func load_enemies(filter_array: Array):
	print("[LOADER] loading enemies: ", filter_array)
	var ret = []
	var enemies = list_files_in_directory(ENEMY_PATH)
	enemies.sort()

	for e in enemies:
		var file = File.new()
		file.open(ENEMY_PATH + e, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			if int(data["ID"]) in filter_array:
				var skills = []
				for id in data["SKILLS"]:
					skills.append(GLOBAL.skills[id])
				ret.append(
					ENEMY_CLASS.new(
						data["ID"],
						data["LEVEL"],
						data["EXPERIENCE"],
						data["IMG"],
						data["ANIM"],
						[
							data["HP"],
							data["HP_MAX"],
							data["MP"],
							data["MP_MAX"],
							data["ATK"],
							data["ATKM"],
							data["DEF"],
							data["DEFM"],
							data["AGI"],
							data["ACC"],
							data["EVA"],
							data["LCK"]
						],
						data["NAME"],
						skills,
						data["RESISTANCE"]
					)
				)
		else:
			print("Error loading enemy", result_json.error)
	return ret

# Loads all itens found in the ITENS_PATH directory.
# TODO: Load only itens that are in inventory/area chests, to avoid wasting memory
func load_all_itens():
	var ret = []
	var itens = list_files_in_directory(ITENS_PATH)
	itens.sort()

	for i in itens:
		var file = File.new()
		file.open(ITENS_PATH + i, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			var effects = []
			for ef in data["EFFECTS"]:
				var eff = STATS_CLASS.new(
					CONSTANTS.DSTAT[ef["STAT"]], ef["STAT"], int(ef["VALUE"]), ef["TYPE"]
				)
				effects.append(eff)
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], CONSTANTS.DSTATUS[st["STATUS"]]])
			ret.append(
				ITEM_CLASS.new(
					data["ID"],
					data["NAME"],
					data["QUANT"],
					data["TARGET"],
					data["TYPE"],
					effects,
					status,
					data["IMG"],
					data["ANIM"]
				)
			)
		else:
			print("Error loading item", result_json.error)
	return [0] + ret


# TODO: Load only equips that are in inventory/area chests, to avoid wasting memory
# Loads all equipment found in the EQUIPS_PATH directory.
func load_all_equips():
	var ret = []
	var equips = list_files_in_directory(EQUIPS_PATH)
	equips.sort()
	for i in equips:
		var file = File.new()
		file.open(EQUIPS_PATH + i, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			var effects = []
			for ef in data["EFFECTS"]:
				var eff = STATS_CLASS.new(
					CONSTANTS.DSTAT[ef["STAT"]], ef["STAT"], int(ef["VALUE"]), ef["TYPE"]
				)
				effects.append(eff)
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], CONSTANTS.DSTATUS[st["STATUS"]]])
			ret.append(
				EQUIP_CLASS.new(
					data["ID"],
					data["NAME"],
					data["TYPE"],
					data["LOCATION"],
					data["CLASS"],
					effects,
					status,
					data["PRICE"],
					data["IMG"]
				)
			)
		else:
			print("Error loading equip", result_json.error)
	return [0] + ret


# TODO: Load only skills from players/enemies in the area, to avoid wasting memory
# Loads all skills found in the SKILLS_PATH directory.
func load_all_skills():
	var ret = []
	var itens = list_files_in_directory(SKILLS_PATH)
	itens.sort()

	for s in itens:
		var file = File.new()

		file.open(SKILLS_PATH + s, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:  # If parse OK
			var data = result_json.result
			var effects = []
			for ef in data["EFFECTS"]:
				var eff = STATS_CLASS.new(
					CONSTANTS.DSTAT[ef["STAT"]], ef["STAT"], int(ef["VALUE"]), ef["TYPE"]
				)
				effects.append(eff)
			var status = []
			for st in data["STATUS"]:
				status.append([st["BOOL"], CONSTANTS.DSTATUS[st["STATUS"]]])
			ret.append(
				ITEM_CLASS.new(
					data["ID"],
					data["NAME"],
					data["QUANT"],
					data["TARGET"],
					data["TYPE"],
					effects,
					status,
					data["IMG"],
					data["ANIM"]
				)
			)

	return [0] + ret

# Loads all statuses found in the STATUS_PATH directory.
func load_all_statuses():
	var ret = {}
	var statuses = list_files_in_directory(STATUS_PATH)
	statuses.sort()

	for s in statuses:
		var file = File.new()

		file.open(STATUS_PATH + s, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:  # If parse OK
			var data = result_json.result
			ret[data["NAME"]] = [data["AURA"]["COLOR"], data["AURA"]["THICKNESS"]]
		else:
			print("Error loading status", result_json.error)
	return ret

# Loads various flags related to the state of the world
func load_flags(slot: int):
	var path = FLAGS_PATH
	if slot >= 0:
		path = SAVE_PATH + "slot" + str(slot) + "/Flags.json"
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		return result_json.result
	else:  # If parse has errors
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)

# Loads information regarding the players' inventory.
# If it's a new game, loads it from Demo_Data.
func load_inventory(slot: int):
	var path = INVENTORY_PATH
	if slot >= 0:
		path = SAVE_PATH + "slot" + str(slot) + "/Inventory.json"
	return parse_inventory(path)

# Loads information regarding the players' equipment.
# If it's a new game, loads it from Demo_Data.
func load_equip(slot: int):
	var path = EQUIPMENT_PATH
	if slot >= 0:
		path = SAVE_PATH + "slot" + str(slot) + "/Equipament.json"
	return parse_equipaments(path)

# Uses information from load_inventory to build the actual inventory
# Path contains a json with item ids and quantity in inventory
func parse_inventory(path: String):
	var file = File.new()
	file.open(path, file.READ)
	var itens = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var data = result_json.result
		for item in data:
			var item_copy = GLOBAL.itens[item["ID"]].clone()
			itens.append(item_copy)
			item_copy.quantity = item["QUANT"]
	return itens

# Uses information from load_equips to build the actual equip inventory
# Path contains a json with item ids and quantity in equip inventory
func parse_equipaments(path: String):
	var file = File.new()
	file.open(path, file.READ)
	var equips = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var data = result_json.result
		for equip in data:
			var equip_copy = GLOBAL.equipment[equip["ID"]].clone()
			equips.append(equip_copy)
			equip_copy.quantity = equip["QUANT"]
	return equips

# Loads information regarding the players' characters.
# If it's a new game, loads it from Demo_Data.
func load_players(slot: int):
	var path = PLAYERS_PATH
	if slot >= 0:
		path = SAVE_PATH + "slot" + str(slot) + "/Players.json"
	return parse_players(path)

# Loads information regarding the reserve party members
# If it's a new game, loads it from Demo_Data.
func load_reserve_players(slot: int):
	var path = RESERVE_PLAYERS_PATH
	if slot >= 0:
		path = SAVE_PATH + "slot" + str(slot) + "/Reserve_Players.json"
	return parse_players(path)

# Loads NPCs found in the NPCS_PATH directory,
# filtered by the ids on filter_array
func load_npcs(filter_array: Array):
	print("[LOADER] loading NPCs: ", filter_array)
	var npcs = list_files_in_directory(NPCS_PATH)
	npcs.sort()
	var ret = []
	for npc in npcs:
		var file = File.new()
		file.open(NPCS_PATH + npc, file.READ)
		var text = file.get_as_text()
		var result_json = JSON.parse(text)
		if result_json.error == OK:
			var data = result_json.result
			if int(data["ID"]) in filter_array:
				ret.append(
					NPC_CLASS.new(
						data["ID"],
						data["NAME"],
						data["IMG"],
						data["ANIM"],
						parse_events(data["EVENTS"]),
						data["PORTRAIT"]
					)
				)
		else:
			print("Error loading NPCs", result_json.error)
	return ret

# Parse an array of event JSON (events) and create their
# respective classes
# in_battle is the instance of the battle event these events belong to
# (used for getting reference to the entities in battle)
func parse_events(events: Array, in_battle = null):
	var parsed_events = []
	for event in events:
		var event_instance: Event = null
		if event.has("DIALOGUE"):
			if typeof(event["DIALOGUE"]) == TYPE_ARRAY:
				event_instance = DIALOGUE_CLASS.new(event["DIALOGUE"])
			else:
				event_instance = DIALOGUE_CLASS.new(
					event["DIALOGUE"]["MESSAGE"],
					event["DIALOGUE"]["NAME"],
					event["DIALOGUE"]["PORTRAIT"]
				)
		elif event.has("OPTIONS"):
			for option in event["OPTIONS"]:
				if event_instance != null:
					parsed_events.append(event_instance)
				event_instance = OPTION_CLASS.new(option["OPTION"], parse_events(option["RESULTS"]))
		elif event.has("TRANSITION"):
			var transition = event["TRANSITION"]
			event_instance = TRANSITION_CLASS.new(
				transition["AREA"], transition["MAP"], LOCAL.parse_position(transition["POSITION"])
			)
		elif event.has("SHOP"):
			var shop = event["SHOP"]
			var subtype = ""
			var itens_sold = []
			if shop.has("ITENS"):
				subtype = "ITEM"
				itens_sold = shop["ITENS"]
			else:
				subtype = "EQUIP"
				itens_sold = shop["EQUIPAMENTS"]
			event_instance = SHOP_CLASS.new(subtype, itens_sold)
		elif event.has("BATTLE"):
			var battle = event["BATTLE"]
			event_instance = BATTLE_CLASS.new(
				battle["ENEMIES"], battle["BACKGROUND"], battle["MUSIC"]
			)
			var battle_events = parse_events(battle["EVENTS"], event_instance)
			event_instance.add_events(battle_events)
		elif event.has("SET_TARGET"):
			var set_target = event["SET_TARGET"]
			var entity = in_battle.find_entity_by_name(set_target["ENTITY"])
			var target = in_battle.find_entity_by_name(set_target["TARGET"])
			event_instance = SET_TARGET_CLASS.new(entity, target, set_target["TURNS"])
		elif event.has("SET_ACTION"):
			var set_action = event["SET_ACTION"]
			var entity = in_battle.find_entity_by_name(set_action["ENTITY"])
			var forced = event["SET_ACTION"].get("FORCE", false)
			var action = event["SET_ACTION"]["ACTION"]
			event_instance = SET_ACTION_CLASS.new(
				entity,
				action["TYPE"],
				action["ARG"],
				action["TARGETS"],
				set_action["TURNS"],
				forced
			)
		elif event.has("FLAG"):
			var flag = event["FLAG"]
			event_instance = FLAG_CLASS.new(flag["KEY"], flag["VALUE"])
		elif event.has("REINFORCEMENTS"):
			var reinforcement = event["REINFORCEMENTS"]
			event_instance = REINFORCEMENT_CLASS.new(
				reinforcement["TYPE"], reinforcement["ENTITIES"]
			)
		if event.has("CONDITION"):
			event_instance.add_condition(event["CONDITION"])
		if event.has("RECURRENCE"):
			event_instance.add_recurrence(event["RECURRENCE"])
		parsed_events.append(event_instance)
	return parsed_events


# TODO: Fix dependency on load_all_skills when it doesn't load everything.
# Uses information from load_skills, load_equips and load_jobs
# to build the actual players.
# Parses the JSON from the player's save file and create instances
# of the Player class
func parse_players(path: String):
	print("[LOADER] loading players from ", path)
	var file = File.new()
	file.open(path, file.READ)
	var players = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var datas = result_json.result
		for data in datas:
			var equips = []
			for id in data["EQUIPS"]:
				if id > -1:
					equips.append(GLOBAL.equipment[id])
				else:
					equips.append(null)
			players.append(
				PLAYER_CLASS.new(
					data["ID"],
					data["LEVEL"],
					data["EXPERIENCE"],
					data["IMG"],
					data["PORTRAIT"],
					data["ANIM"],
					[
						data["HP"],
						data["HP_MAX"],
						data["MP"],
						data["MP_MAX"],
						data["ATK"],
						data["ATKM"],
						data["DEF"],
						data["DEFM"],
						data["AGI"],
						data["ACC"],
						data["EVA"],
						data["LCK"]
					],
					data["LANE"],
					data["NAME"],
					data["SKILLS"],
					equips,
					data["RESISTANCE"],
					data["JOBS"]
				)
			)
			for i in range(len(equips)):
				if data["EQUIPS"][i] > -1:
					players[-1].equip(equips[i], i)
	else:
		print("Error loading players", result_json.error)
	return players

# Loads random lore tidbits for displaying on a load screen
func get_random_lore():
	var lores = list_files_in_directory(LORES_PATH)
	lores.shuffle()
	var file = File.new()
	file.open(LORES_PATH + lores[0], file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		return result_json.result
	else:
		print("Error loading lore", result_json.error)

# Loads all jobs found in the JOBS_PATH directory.
func load_all_jobs():
	print("[LOADER] loading jobs")
	var file = File.new()
	file.open(JOBS_PATH, file.READ)
	var jobs = []
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var datas = result_json.result
		for data in datas:
			var skills = {}
			for lv in data["SKILLS"].keys():
				var lv_parsed = int(lv.replace("LV", ""))
				skills[lv_parsed] = GLOBAL.skills[data["SKILLS"][lv]]
			jobs.append(JOB_CLASS.new(data["ID"], data["NAME"], data["PROFICIENCIES"], skills))
	else:
		print("Error loading jobs", result_json.error)
	return jobs
