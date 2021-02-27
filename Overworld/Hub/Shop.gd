extends Control

var itens = []

onready var item_container = $ItemList/ScrollContainer/VBoxContainer
onready var item_button = load("res://Overworld/Hub/ItemButton.tscn")
onready var dialogue = $Dialogue/Text
onready var stock = $PlayerInfo/HBoxContainer/StockValue
onready var money = $PlayerInfo/HBoxContainer/MoneyValue
onready var confirmation = $Confirmation
onready var quantity = $Quantity
onready var mode = $Mode

var selected_item = null
var last_selected = 0
var item_quantity = 1
var last_shop_visited = -1
var shop_id = -1
var MODE = "BUY"


# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue.set_text("Welcome! How can I help you?")
	money.set_text(str(GLOBAL.gold)+"G")

# Enter shop with specified id
func enter(id: int):
	print("entering...")
	shop_id = id
	dialogue.set_text("Welcome! How can I help you?")
	money.set_text(str(GLOBAL.gold)+"G")
	mode.show()
	mode.get_node("Buy").grab_focus()
	print("vou limpar")
	clear_items()

func load_items(item_ids: Array):
	var count = 0
	itens = []
	for i in range(1, len(GLOBAL.ITENS)):
		var item = GLOBAL.ITENS[i]
		if item.id in item_ids:
			itens.append(item)
			item_container.add_child(item_button.instance())
			var item_btn = item_container.get_child(count)
			item_btn.set_name(item.nome)
			item_btn.set_cost(item.quantity)
			if MODE == "SELL":
				item_btn.set_cost(floor(item.quantity / 2))
			item_btn.connect("pressed", self, "_on_Item_Selected", [count])
			item_btn.connect("focus_entered", self, "_on_Item_Hovered", [count])
			count += 1
	update_items()

func clear_items():
	print("clearing items")
	for i in item_container.get_children():
		i.queue_free()

func update_items(has_focus=false):
	money.set_text(str(GLOBAL.gold)+"G")
	for i in range(len(itens)):
		item_container.get_child(i).disable()
		if MODE == "BUY":
			if itens[i].quantity <= GLOBAL.get_gold():
				item_container.get_child(i).enable()
				if not has_focus:
					has_focus = true
					print("Setting focus: ", i)
					item_container.get_child(i).grab_focus()
		elif MODE == "SELL":
			if GLOBAL.check_item(itens[i].id) <= 0:
				item_container.get_child(i).hide()
			else:
				item_container.get_child(i).enable()
				if not has_focus:
					has_focus = true
					print("Setting focus: ", i)
					item_container.get_child(i).grab_focus()

func _on_Item_Selected(id: int):
	AUDIO.play_se("ENTER_MENU")
	last_selected = id
	if selected_item.quantity > GLOBAL.get_gold():
		dialogue.set_text("Oops, not enough money!")
	dialogue.set_text("How much?")
	item_quantity = 1
	quantity.get_node("SpinBox").value = 1
	quantity.show()
	if MODE == "BUY":
		quantity.get_node("SpinBox").max_value = floor(GLOBAL.get_gold() / selected_item.quantity)
	elif MODE == "SELL":
		quantity.get_node("SpinBox").max_value = GLOBAL.check_item(selected_item.id)
	quantity.get_node("SpinBox").grab_focus()

func _on_Item_Hovered(id: int):
	AUDIO.play_se("MOVE_MENU")
	print("Item hovered ", id)
	selected_item = itens[id]
	var qty_in_stock = GLOBAL.check_item(selected_item.id)
	stock.set_text(str(qty_in_stock)+"x")
	var description = "  "+selected_item.get_name()+\
	"\n  Type: "+selected_item.get_type()+"\n  Targets: "+\
	selected_item.get_target()
	$ItemInfo/Description.set_text(description)


func _on_Yes_pressed():
	AUDIO.play_se("MONEY", 4)
	dialogue.set_text("Thank you! Anything else you need?")
	var has_focus = false
	if MODE == "BUY":
		GLOBAL.add_item(selected_item.id, item_quantity)
		GLOBAL.gold -= item_quantity*selected_item.quantity
		if GLOBAL.gold >= selected_item.quantity:
			print("Setting focus: ", last_selected)
			item_container.get_child(last_selected).grab_focus()
			has_focus = true
	elif MODE == "SELL":
		GLOBAL.add_item(selected_item.id, -item_quantity)
		GLOBAL.gold += item_quantity*(selected_item.quantity/2)
		if GLOBAL.check_item(selected_item.id) > 0:
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
		AUDIO.play_se("EXIT_MENU")
		print("cancel pressed")
		if confirmation.visible or quantity.visible:
			print("no no")
			_on_No_pressed()
		elif mode.visible:
			print("will exit")
			_exit_Store()
		else:
			print("will enter")
			enter(shop_id)
	elif quantity.visible and not confirmation.visible:
		if event.is_action_pressed("ui_accept"):
			AUDIO.play_se("ENTER_MENU")
			print("Ya buying??")
			var price = selected_item.quantity
			var verb = "buying"
			if MODE == "SELL":
				verb = "selling"
				price = selected_item.quantity / 2
			dialogue.set_text("You "+str(verb)+" "+str(item_quantity)+" "+selected_item.nome+" for "+str(price*item_quantity)+"G?")
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
	AUDIO.play_se("MOVE_MENU")
	item_quantity = value


func _on_Buy_pressed():
	AUDIO.play_se("ENTER_MENU")
	MODE = "BUY"
	var item_ids = GLOBAL.SHOPS[shop_id].get_itens()
	load_items(item_ids)
	mode.hide()


func _on_Sell_pressed():
	AUDIO.play_se("ENTER_MENU")
	MODE = "SELL"
	var item_ids = GLOBAL.get_item_ids()
	load_items(item_ids)
	mode.hide()


func _on_Buy_focus_entered():
	AUDIO.play_se("MOVE_MENU")


func _on_Sell_focus_entered():
	AUDIO.play_se("MOVE_MENU")
