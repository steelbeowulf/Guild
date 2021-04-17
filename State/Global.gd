extends Node

# Global variables containing all loaded itens, skills and enemies
var ITENS
var SKILLS
var STATUS
var ENEMIES
var NPCS
var EQUIPAMENT

var gold
var playtime

# Global variables containing current players info (party and inventory)
var PLAYERS
var INVENTORY
var EQUIP_INVENTORY

onready var loader = get_node("/root/LOADER")

# Load global stuff
func load_game(slot):
	# Global data
	STATUS = loader.load_all_statuses()
	SKILLS = loader.load_all_skills()
	ITENS = loader.load_all_itens()
	EQUIPAMENT = loader.load_all_equips()
	
	#ENEMIES = loader.load_enemies()
	
	# Saved data
	var saved_data = SAVE.load_game(slot)
	INVENTORY = saved_data["Inventory"]
	EQUIP_INVENTORY = saved_data["Equip_Inventory"]
	PLAYERS = saved_data["Players"]
#{
#	"Inventory": loader.load_inventory(save_slot),
#	"Equip_Inventory": loader.load_equip(save_slot),
#	"Players": loader.load_players(save_slot),
#	"Area_Info": load_info(save_slot),
#	"Enemies_in_area": area_info["ENEMIES"],
#	"NPCs_in_area": area_info["NPCS"]
#}

# Helper function to get the Root node
func get_root():
	return get_node("/root/Root")

func get_playtime():
	return playtime

func get_gold():
	return gold

# Get item ids from inventory
func get_item_ids():
	var item_ids = []
	for item in INVENTORY:
		item_ids.append(item.id)
	return item_ids


# Get item ids from equip_inventory
func get_equip_ids():
	var item_ids = []
	for item in EQUIP_INVENTORY:
		item_ids.append(item.id)
	return item_ids


# Check if item_id is in inventory
func check_item(item_id: int, type="ITEM"):
	var inventory = INVENTORY
	if type == "EQUIP":
		inventory = EQUIP_INVENTORY
	for item in inventory:
		if item.id == item_id:
			return item.quantity
	return 0


# Adds the item with item_id to the inventory, with quantity of item_quantity
func add_item(item_id: int, item_quantity: int):
	for item in INVENTORY:
		if item.id == item_id:
			item.quantity += item_quantity
			return
	var item = ITENS[item_id]._duplicate()
	item.quantity = item_quantity
	INVENTORY.append(item)


# Clone of the add_item function, but for equipaments
func add_equip(equip_id: int, equip_quantity: int):
	for equip in EQUIP_INVENTORY:
		if equip.id == equip_id:
			equip.quantity += equip_quantity
			return
	var equip = EQUIPAMENT[equip_id]._duplicate()
	equip.quantity = equip_quantity
	EQUIP_INVENTORY.append(equip)


# Checks if equip with equip_id is equipped on someone from the party
func is_equipped(equip_id: int):
	for e in EQUIP_INVENTORY:
		if e.id == equip_id:
			return e.equipped
