extends Control
var item = null
onready var location = "OUTSIDE"  # TODO: fix this


func _ready():
	give_focus()
	var item_nodes = $Panel/HBoxContainer/Itens.get_children()
	for i in range(len(item_nodes)):
		var node = item_nodes[i]
		node.connect("target_picked", self, "_on_Item_selected", [i])
		node.connect("target_selected", self, "_on_Item_hover", [i])
	for btn in $Panel/HBoxContainer/Options.get_children():
		btn.connect("focus_entered", self, "_on_focus_entered")
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()
	show_itens(GLOBAL.inventory)


func just_entered():
	location = "SUBMENU"


func show_itens(bag: Array):
	for i in range(len(bag)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].name) + " x " + str(bag[i].quantity))
		node.show()
		if bag[i].quantity <= 0:
			node.hide()
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()
	for e in $Panel/HBoxContainer/Itens.get_children():
		e.set_focus_mode(0)


func update_itens(bag: Array):
	for i in range(len(bag)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].name) + " x " + str(bag[i].quantity))
		if bag[i].quantity == 0:
			node.disabled = true
			node.hide()
		else:
			node.disabled = false
			node.show()


func _on_Item_selected(id: int):
	AUDIO.play_se("ENTER_MENU")
	item = GLOBAL.inventory[id]
	var name = item.get_name()
	print("[Itens] Selected " + str(name))
	use_item(item)


func _on_Item_hover(id):
	AUDIO.play_se("MOVE_MENU")
	item = GLOBAL.inventory[id]
	var name = item.get_name()
	print("[Itens] Hovered " + str(name))
	set_description(item)


func set_description(item: Item):
	print("Set description")
	var description = (
		"  "
		+ item.get_name()
		+ "\n  Type: "
		+ item.get_type()
		+ "\n  Targets: "
		+ item.get_target()
	)
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)


func use_item(item: Item):
	get_parent().get_parent().get_parent().use_item(item)


func _on_Use_pressed():
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Itens.get_children():
		e.set_focus_mode(2)
	location = "ITENS"
	for i in range(len(GLOBAL.inventory)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		if node.disabled == false:
			get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i)).grab_focus()
			break
	#get_node("Panel/HBoxContainer/Itens/ItemSlot0").grab_focus()


func _process(_delta):
	update_itens(GLOBAL.inventory)
	if Input.is_action_just_pressed("ui_cancel") and location == "ITENS":
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "SUBMENU":
		location = "OUTSIDE"
		get_parent().get_parent().get_parent().return_menu()


func give_focus():
	$Panel/HBoxContainer/Options/Use.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Organize.set_focus_mode(2)
	$Panel/HBoxContainer/Options/KeyItens.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Itens.get_children():
		e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()


func _on_Back_pressed():
	print(location)
	AUDIO.play_se("EXIT_MENU")
	location = "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()


func _on_focus_entered():
	AUDIO.play_se("MOVE_MENU")
