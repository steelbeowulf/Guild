extends Control

var itens = []

onready var item_container = $ItemList/ScrollContainer/VBoxContainer
onready var item_button = load("res://Overworld/Hub/ItemButton.tscn")
onready var dialogue = $Dialogue/Text
onready var stock = $PlayerInfo/HBoxContainer/StockValue
onready var money = $PlayerInfo/HBoxContainer/MoneyValue
onready var confirmation = $Confirmation

var selected_item = null
var last_selected = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue.set_text("Welcome!")
	money.set_text(str(GLOBAL.gold)+"G")

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
			item_btn.connect("focus_entered", self, "_on_Item_Hovered", [count])
			count += 1
	update_items()
	item_container.get_child(0).grab_focus()

func update_items():
	money.set_text(str(GLOBAL.gold)+"G")
	for i in range(len(itens)):
		if itens[i].quantity > GLOBAL.get_gold():
			item_container.get_child(i).disable()

func _on_Item_Selected(id: int):
	print("ITEM SELECTED", id)
	last_selected = id
	if selected_item.quantity > GLOBAL.get_gold():
		dialogue.set_text("Oops, not enough money!")
	dialogue.set_text("You buying a "+selected_item.nome+" for "+str(selected_item.quantity)+"G?")
	confirmation.show()
	confirmation.get_node("Yes").grab_focus()

func _on_Item_Hovered(id: int):
	print("ITEM HOVERED", id)
	selected_item = itens[id]
	# TODO: Fix check for item on inventory
	var qty_in_stock = GLOBAL.check_item(selected_item.id)
	stock.set_text(str(qty_in_stock)+"x")


func _on_Yes_pressed():
	# TODO: Play ka-ching!
	dialogue.set_text("Thank you! Anything else you need?")
	GLOBAL.add_item(selected_item.id, 1)
	GLOBAL.gold -= selected_item.quantity
	update_items()
	confirmation.hide()
	item_container.get_child(0).grab_focus()


func _on_No_pressed():
	dialogue.set_text("Oh, ok, take your time choosing then")
	item_container.get_child(last_selected).grab_focus()
	confirmation.hide()

func _exit_Store():
	dialogue.set_text("Thanks, come back anytime!")
	$Timer.start()
	yield($Timer, "timeout")
	get_parent().get_parent().close_shop()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if confirmation.visible:
			_on_No_pressed()
		else:
			_exit_Store()