extends Control

var itens = []

onready var item_container = $ItemList/ScrollContainer/VBoxContainer
onready var item_button = load("res://Overworld/Hub/ItemButton.tscn")
onready var dialogue = $Dialogue/Text
onready var stock = $PlayerInfo/HBoxContainer/StockValue
onready var money = $PlayerInfo/HBoxContainer/MoneyValue
onready var confirmation = $Confirmation
onready var quantity = $Quantity

var selected_item = null
var last_selected = 0
var item_quantity = 1
var last_shop_visited = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue.set_text("Welcome!")
	money.set_text(str(GLOBAL.gold)+"G")

# Enter shop with specified id
func enter(id: int):
	if last_shop_visited != -1 and last_shop_visited == id:
		update_items()
		dialogue.set_text("Welcome!")
		money.set_text(str(GLOBAL.gold)+"G")
		return
	var count = 0
	var item_ids = GLOBAL.SHOPS[id].get_itens()
	while len(item_container.get_children()) > 0:
		item_container.get_child(0).queue_free()
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
	last_shop_visited = id

func update_items(has_focus=false):
	money.set_text(str(GLOBAL.gold)+"G")
	for i in range(len(itens)):
		item_container.get_child(i).disable()
		if itens[i].quantity <= GLOBAL.get_gold():
			item_container.get_child(i).enable()
			if not has_focus:
				has_focus = true
				print("Setting focus: ", i)
				item_container.get_child(i).grab_focus()

func _on_Item_Selected(id: int):
	last_selected = id
	if selected_item.quantity > GLOBAL.get_gold():
		dialogue.set_text("Oops, not enough money!")
	dialogue.set_text("How much?")
	item_quantity = 1
	quantity.get_node("SpinBox").value = 1
	quantity.show()
	quantity.get_node("SpinBox").max_value = floor(GLOBAL.get_gold() / selected_item.quantity)
	quantity.get_node("SpinBox").grab_focus()

func _on_Item_Hovered(id: int):
	print("Item hovered ", id)
	selected_item = itens[id]
	var qty_in_stock = GLOBAL.check_item(selected_item.id)
	stock.set_text(str(qty_in_stock)+"x")


func _on_Yes_pressed():
	# TODO: Play ka-ching!
	dialogue.set_text("Thank you! Anything else you need?")
	GLOBAL.add_item(selected_item.id, item_quantity)
	GLOBAL.gold -= item_quantity*selected_item.quantity
	var has_focus = false
	if GLOBAL.gold >= selected_item.quantity:
		print("Setting focus: ", last_selected)
		item_container.get_child(last_selected).grab_focus()
		has_focus = true
	update_items(has_focus)
	confirmation.hide()
	quantity.hide()


func _on_No_pressed():
	dialogue.set_text("Oh, ok, take your time choosing then")
	item_container.get_child(last_selected).grab_focus()
	confirmation.hide()
	quantity.hide()

func _exit_Store():
	dialogue.set_text("Thanks, come back anytime!")
	$Timer.wait_time = 1.0
	$Timer.start()
	yield($Timer, "timeout")
	get_parent().get_parent().close_shop()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if confirmation.visible or quantity.visible:
			_on_No_pressed()
		else:
			_exit_Store()
	elif quantity.visible and not confirmation.visible:
		if event.is_action_pressed("ui_accept"):
			print("Ya buying??")
			dialogue.set_text("You buying "+str(item_quantity)+" "+selected_item.nome+" for "+str(selected_item.quantity*item_quantity)+"G?")
			confirmation.show()
			$Timer.wait_time = 0.1
			$Timer.start()
			yield($Timer, "timeout")
			confirmation.get_node("Yes").grab_focus()
		elif event.is_action_pressed("ui_up"):
			quantity.get_node("SpinBox").value += 1
		elif event.is_action_pressed("ui_down"):
			quantity.get_node("SpinBox").value -= 1


func _on_SpinBox_value_changed(value):
	item_quantity = value
