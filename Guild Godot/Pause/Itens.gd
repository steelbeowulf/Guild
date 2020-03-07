extends Control
var x = 0
onready var location = "OUTSIDE" #this doesnt work yet, pressing esc on the menu opens the item menu

func _ready():
	give_focus()
	for c in $Panel/HBoxContainer/Itens.get_children():
		c.connect("target_picked", self, "_on_Item_selected")
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()
	show_itens(GLOBAL.INVENTORY)

func just_entered():
	location = "SUBMENU"

func show_itens(bag):
	for i in range(len(bag)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].nome) + " x " + str(bag[i].quantity))
		node.show()
		if bag[i].quantity == 0:
			node.hide()
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()
	for e in $Panel/HBoxContainer/Itens.get_children():
			e.set_focus_mode(0)

func update_itens(bag):
	for i in range(len(bag)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].nome) + " x " + str(bag[i].quantity))
		if bag[i].quantity == 0:
			node.hide()

func _on_Item_selected(name):
	var namearray = name.split(" x ", true, 1)
	var nome = namearray[0]
	use_item(nome)

func use_item(namex):
	
	get_parent().get_parent().use_item(namex)

func _on_Use_pressed():
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Itens.get_children():
		e.set_focus_mode(2)
	location = "ITENS"
	
	
	get_node("Panel/HBoxContainer/Itens/ItemSlot0").grab_focus()

func _process(delta):
	update_itens(GLOBAL.INVENTORY)
	if Input.is_action_pressed("ui_cancel") and location == "ITENS":
		location == "SUBMENU"
		give_focus()
	elif Input.is_action_pressed("ui_cancel") and location == "SUBMENU":
		location == "OUTSIDE"
		get_parent().get_parent().open_menu()

func give_focus():
	$Panel/HBoxContainer/Options/Use.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Organize.set_focus_mode(2)
	$Panel/HBoxContainer/Options/KeyItens.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Itens.get_children():
			e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()