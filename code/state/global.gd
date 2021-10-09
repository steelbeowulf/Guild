extends Node

# Global variables containing all loaded itens, skills and enemies
var itens
var skills
var status
var equipment
var jobs

var gold
var playtime

# Global variables containing current players info (party and inventory)
var players
var inventory
var equipment_inventory
var reserve_players

onready var loader = get_node("/root/LOADER")


# Load global stuff
func load_game(slot):
	# Global data
	status = loader.load_all_statuses()
	skills = loader.load_all_skills()
	itens = loader.load_all_itens()
	equipment = loader.load_all_equips()
	jobs = loader.load_all_jobs()

	# Saved data
	var saved_data = SAVE.load_game(slot)
	print("[GLOBAL load_game] ", saved_data)
	playtime = saved_data["Area_Info"]["Playtime"]
	gold = saved_data["Area_Info"]["Gold"]
	inventory = saved_data["Inventory"]
	equipment_inventory = saved_data["Equip_Inventory"]
	reserve_players = saved_data["Reserve_Players"]
	players = saved_data["Players"]
	LOCAL.load_enemies(saved_data["Enemies_in_area"])
	LOCAL.load_npcs(saved_data["NPCs_in_area"])
	EVENTS.load_flags(saved_data["Flags"])


# Helper function to get the Root node
func get_root():
	return get_node("/root/Root")


# Get playtime
func get_playtime():
	return playtime


# Get gold
func get_gold():
	return gold


# Get item ids from inventory
func get_item_ids():
	var item_ids = []
	for item in inventory:
		item_ids.append(item.id)
	return item_ids


func get_player(player_id):
	for p in players:
		if p.id == player_id:
			return p


func get_reserve_player(player_id):
	for p in reserve_players:
		if p.id == player_id:
			return p


# Get item ids from equipment_inventory
func get_equip_ids():
	var item_ids = []
	for item in equipment_inventory:
		item_ids.append(item.id)
	return item_ids


# Check if item_id is in inventory
func check_item(item_id: int, type = "ITEM"):
	var inventory = inventory
	if type == "EQUIP":
		inventory = equipment_inventory
	for item in inventory:
		if item.id == item_id:
			return item.quantity
	return 0


# Adds the item with item_id to the inventory, with quantity of item_quantity
func add_item(item_id: int, item_quantity: int):
	for item in inventory:
		if item.id == item_id:
			item.quantity += item_quantity
			return
	var item = itens[item_id].clone()
	item.quantity = item_quantity
	inventory.append(item)


# Clone of the add_item function, but for equipments
func add_equip(equip_id: int, equip_quantity: int):
	for equip in equipment_inventory:
		if equip.id == equip_id:
			equip.quantity += equip_quantity
			return
	var equip = equipment[equip_id].clone()
	equip.quantity = equip_quantity
	equipment_inventory.append(equip)


# Checks if equip with equip_id is equipped on someone from the party
func is_equipped(equip_id: int):
	for e in equipment_inventory:
		if e.id == equip_id:
			return e.equipped
