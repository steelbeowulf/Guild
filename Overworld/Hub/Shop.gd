extends Control

var itens = []

onready var item_container = $ItemList/ScrollContainer/VBoxContainer
onready var item_button = load("res://Overworld/Hub/ItemButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Enter shop with specified id
func enter(id: int):
	var count = 0
	var item_ids = GLOBAL.SHOPS[id].get_itens()
	for i in range(1, len(GLOBAL.ITENS)):
		var item = GLOBAL.ITENS[i]
		if item.id in item_ids:
			itens.append(item)
			item_container.add_child(item_button.instance())
			var item_btn = item_container.get_child(count)
			item_btn.set_name(item.nome)
			item_btn.set_cost(item.quantity)
			item_btn.connect("pressed", self, "_on_Item_Selected", [count])
			count += 1

func _on_Item_Selected(id: int):
	print("ITEM SELECTED", id)