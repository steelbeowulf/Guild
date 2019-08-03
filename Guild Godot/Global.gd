extends Node

var ALL_ITENS
var ALL_SKILLS
var ALL_ENEMIES
var ALL_PLAYERS
var INVENTORY
var POSITION

func add_item(item_id, item_quantity):
	var done = false
	for item in INVENTORY:
		if item == ALL_ITENS[item_id]:
			item.quantity += item_quantity
			done = true
			break
	if not done:
		var item = ALL_ITENS[item_id].duplicate()
		item.quantity += item_quantity
		INVENTORY.add(item)
