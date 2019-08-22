extends Node

var ALL_ITENS
var ALL_SKILLS
var ALL_ENEMIES
var ALL_PLAYERS
var INVENTORY
var POSITION
var STATE = {1:{}, 2:{}, 3:{}, 4:{}, 5:{}, 6:{}, 7:{}, 8:{}, 9:{}, 10:{},
	11:{}, 12:{}, 13:{}, 14:{}, 15:{}}
var TRANSITION
var MAP
var WIN
onready var MATCH = false
onready var ROOM = false

func reload_state():
	WIN = false
	STATE = {1:{}, 2:{}, 3:{}, 4:{}, 5:{}, 6:{}, 7:{}, 8:{}, 9:{}, 10:{},
	11:{}, 12:{}, 13:{}, 14:{}, 15:{}}
	MATCH = false
	ROOM = false
	TRANSITION = null
	MAP = null
	POSITION = null

func add_item(item_id, item_quantity):
	var done = false
	for item in INVENTORY:
		if item == ALL_ITENS[item_id]:
			item.quantity += item_quantity
			done = true
			break
	if not done:
		var item = ALL_ITENS[item_id]
		item.quantity += item_quantity
		INVENTORY.append(item)
