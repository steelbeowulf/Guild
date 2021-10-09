extends Control

var itens = []

onready var item_container = $ItemList/ScrollContainer/VBoxContainer
onready var item_button = load("res://code/overworld/npcs/shop/item_button.tscn")
onready var dialogue = $Dialogue/Text
onready var stock = $PlayerInfo/HBoxContainer/StockValue
onready var money = $PlayerInfo/HBoxContainer/MoneyValue
onready var confirmation = $Confirmation
onready var quantity = $Quantity
onready var mode = $Mode

var selected_item = null
var last_selected = 0
var last_hovered = 0
var selected_player = -1
var item_quantity = 1
var last_shop_visited = null
var goods_ids = []
var should_equip = false
var MODE = "BUY"
var SHOP_TYPE = "ITEM"


# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue.set_text("Welcome! How can I help you?")
	money.set_text(str(GLOBAL.gold)+"G")
	for i in range(len(GLOBAL.players)):
		$ItemInfo/PartyPortraits.get_child(i).init(i)
		$ItemInfo/PartyPortraits.get_child(i).connect("button_down", self, "_select_player", [i])
	set_process(false)

# Enter shop with specified id
func enter(shop: Event):
	last_shop_visited = shop
	goods_ids = shop.get_goods()
	SHOP_TYPE = shop.get_subtype()
	dialogue.set_text("Welcome! How can I help you?")
	money.set_text(str(GLOBAL.gold)+"G")
	mode.show()
	mode.get_node("Buy").grab_focus()
	clear_items()

func load_items(item_ids: Array):
	var count = 0
	itens = []
	for i in range(1, len(GLOBAL.itens)):
		var item = GLOBAL.itens[i]
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
			item_btn.connect("mouse_entered", self, "_on_Item_Hovered", [count])
			count += 1
	update_items()

func load_equips(item_ids: Array, sell=false):
	var count = 0
	itens = []
	for i in range(1, len(GLOBAL.equipment)):
		var item = GLOBAL.equipment[i]
		if item.id in item_ids:
			itens.append(item)
			item_container.add_child(item_button.instance())
			var item_btn = item_container.get_child(count)
			var additional = ""
			if sell and item.equipped > -1:
				additional = " (E)"
			item_btn.set_name(item.get_name()+additional)
			item_btn.set_cost(item.get_cost())
			if MODE == "SELL":
				item_btn.set_cost(floor(item.quantity / 2))
			item_btn.connect("pressed", self, "_on_Item_Selected", [count])
			item_btn.connect("focus_entered", self, "_on_Equip_Hovered", [count])
			item_btn.connect("mouse_entered", self, "_on_Equip_Hovered", [count])
			count += 1
	update_items()

func clear_items():
	for i in item_container.get_children():
		i.queue_free()

func update_items(has_focus=false):
	money.set_text(str(GLOBAL.gold)+"G")
	should_equip = false
	for i in range(len(itens)):
		item_container.get_child(i).disable()
		if MODE == "BUY":
			if itens[i].quantity <= GLOBAL.get_gold():
				item_container.get_child(i).enable()
				if not has_focus:
					has_focus = true
					print("[SHOP] Setting focus: ", i)
					item_container.get_child(i).grab_focus()
		elif MODE == "SELL":
			if GLOBAL.check_item(itens[i].id, SHOP_TYPE) <= 0:
				item_container.get_child(i).hide()
			else:
				item_container.get_child(i).enable()
				if not has_focus:
					has_focus = true
					print("[SHOP] Setting focus: ", i)
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
	print("[SHOP] Item hovered ", id)
	selected_item = itens[id]
	last_hovered = id
	var qty_in_stock = GLOBAL.check_item(selected_item.id)
	stock.set_text(str(qty_in_stock)+"x")
	var description = "  "+selected_item.get_name()+\
	"\n  Type: "+selected_item.get_type()+"\n  Targets: "+\
	selected_item.get_target()
	$ItemInfo/Description.set_text(description)

func _on_Equip_Hovered(id: int):
	AUDIO.play_se("MOVE_MENU")
	print("[SHOP] Equip hovered ", id)
	selected_item = itens[id]
	last_hovered = id
	var qty_in_stock = GLOBAL.check_item(selected_item.id)
	stock.set_text(str(qty_in_stock)+"x")
	var description = "  "+selected_item.get_name()+\
	"\n  Type: "+selected_item.get_type()+"\n  Job: "+\
	selected_item.get_job()+"\n  Location: "+selected_item.get_location()
	$ItemInfo/Description.set_text(description)
	var first = selected_player == -1 or (
		GLOBAL.players[selected_player].get_job() != selected_item.get_job() 
		and selected_item.get_job() != "ANY"
	)
	for p in $ItemInfo/PartyPortraits.get_children():
		if p.visible and GLOBAL.players[p.id].get_job() == selected_item.get_job() or selected_item.get_job() == "ANY":
			p.make_active()
			if first:
				_select_player(p.id, false)
				first = false
		else:
			p.make_inactive()
	$ItemInfo/Comparison.init(GLOBAL.players[selected_player].get_equip(selected_item.get_location()), selected_item)


func _select_player(id: int, again=true):
	print("Selecting player ", id, "previous is ", selected_player)
	for i in range(len(GLOBAL.players)):
		print("Setando ", i, " falso")
		$ItemInfo/PartyPortraits.get_child(i).pressed = false
		$ItemInfo/PartyPortraits.get_child(i).set("pressed", false)
		#$ItemInfo/PartyPortraits.get_child(i).pressed()
	if selected_player > -1:
		print($ItemInfo/PartyPortraits.get_child(selected_player).pressed)
	selected_player = id
	$ItemInfo/PartyPortraits.get_child(id).pressed = true
	if again:
		_on_Equip_Hovered(last_hovered)

func _on_Yes_pressed():
	AUDIO.play_se("MONEY", 4)
	if SHOP_TYPE == "EQUIP" and should_equip:
		GLOBAL.players[selected_player].equip(selected_item)
	elif SHOP_TYPE == "EQUIP" and MODE == "BUY":
		dialogue.set_text("Would you like to equip that?")
		should_equip = true
		return
	dialogue.set_text("Thank you! Anything else you need?")
	if MODE == "BUY":
		buy_item()
	elif MODE == "SELL":
		sell_item()


func sell_item():
	var has_focus = false
	if SHOP_TYPE == "EQUIP":
		GLOBAL.add_equip(selected_item.id, -item_quantity)
		var is_equipped = selected_item.equipped
		if is_equipped > -1:
			GLOBAL.players[is_equipped].unequip(selected_item)
	elif SHOP_TYPE == "ITEM":
		GLOBAL.add_item(selected_item.id, -item_quantity)
	GLOBAL.gold += item_quantity*(selected_item.quantity/2)
	if GLOBAL.check_item(selected_item.id, SHOP_TYPE) > 0:
		item_container.get_child(last_selected).grab_focus()
		has_focus = true
	update_items(has_focus)
	confirmation.hide()
	quantity.hide()

func buy_item():
	var has_focus = false
	if SHOP_TYPE == "EQUIP":
		GLOBAL.add_equip(selected_item.id, item_quantity)
	elif SHOP_TYPE == "ITEM":
		GLOBAL.add_item(selected_item.id, item_quantity)
	GLOBAL.gold -= item_quantity*selected_item.quantity
	if GLOBAL.gold >= selected_item.quantity:
		item_container.get_child(last_selected).grab_focus()
		has_focus = true
	update_items(has_focus)
	confirmation.hide()
	quantity.hide()

func _on_No_pressed():
	if SHOP_TYPE == "EQUIP" and should_equip:
		buy_item()
	else:
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

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		print("quero sair AAA")
		AUDIO.play_se("EXIT_MENU")
		if confirmation.visible or quantity.visible:
			_on_No_pressed()
		elif mode.visible:
			_exit_Store()
		else:
			enter(last_shop_visited)
	elif quantity.visible and not confirmation.visible:
		if Input.is_action_just_pressed("ui_accept"):
			AUDIO.play_se("ENTER_MENU")
			var price = selected_item.quantity
			var verb = "buying"
			if MODE == "SELL":
				verb = "selling"
				price = selected_item.quantity / 2
			dialogue.set_text("You "+str(verb)+" "+str(item_quantity)+" "+selected_item.get_name()+" for "+str(price*item_quantity)+"G?")
			confirmation.show()
			$Timer.wait_time = 0.1
			$Timer.start()
			yield($Timer, "timeout")
			confirmation.get_node("Yes").grab_focus()
		elif Input.is_action_pressed("ui_up"):
			quantity.get_node("SpinBox").value += 1
		elif Input.is_action_pressed("ui_down"):
			quantity.get_node("SpinBox").value -= 1


func _on_SpinBox_value_changed(value):
	AUDIO.play_se("MOVE_MENU")
	item_quantity = value


func _on_Buy_pressed():
	AUDIO.play_se("ENTER_MENU")
	MODE = "BUY"
	if SHOP_TYPE == "EQUIP":
		load_equips(goods_ids)
	else:
		load_items(goods_ids)
	mode.hide()


func _on_Sell_pressed():
	AUDIO.play_se("ENTER_MENU")
	MODE = "SELL"
	if SHOP_TYPE == "EQUIP":
		var item_ids = GLOBAL.get_equip_ids()
		load_equips(item_ids, true)
	else:
		var item_ids = GLOBAL.get_item_ids()
		load_items(item_ids)
	mode.hide()


func _on_Buy_focus_entered():
	AUDIO.play_se("MOVE_MENU")


func _on_Sell_focus_entered():
	AUDIO.play_se("MOVE_MENU")
