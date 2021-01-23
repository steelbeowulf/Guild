extends Control
var item = null
onready var location = "OUTSIDE" #this doesnt work yet, pressing esc on the menu opens the item menu

func _ready():
	give_focus()
	var itemNodes = $Panel/HBoxContainer/Itens.get_children()
	for i in range(len(itemNodes)):
		var c = itemNodes[i]
		c.connect("target_picked", self, "_on_Item_selected", [i])
		c.connect("target_selected", self, "_on_Item_hover", [i])
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()
	show_itens(GLOBAL.INVENTORY)

func just_entered():
	location = "SUBMENU"

func show_itens(bag):
	for i in range(len(bag)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].nome) + " x " + str(bag[i].quantity))
		node.show()
		if bag[i].quantity <= 0:
			node.hide()
	get_node("Panel/HBoxContainer/Options/Use").grab_focus()
	for e in $Panel/HBoxContainer/Itens.get_children():
			e.set_focus_mode(0)
	

func update_itens(bag):
	for i in range(len(bag)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].nome) + " x " + str(bag[i].quantity))
		if bag[i].quantity == 0:
			node.disabled = true
			node.hide()
		else:
			node.disabled = false
			node.show()

func _on_Item_selected(id):
	item = GLOBAL.INVENTORY[id]
	var nome = item.get_name()
	print("SELECTED "+str(nome))
	#set_description(item)
	use_item(item)

func _on_Item_hover(id):
	item = GLOBAL.INVENTORY[id]
	var nome = item.get_name()
	print("SELECTED "+str(nome))
	set_description(item)

func set_description(item):
	print("Set description")
	#print(item.get_name())
	var description = "  "+item.get_name()+"\n  Type: "+item.get_type()+"\n  Targets: "+item.get_target()
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)

func use_item(item):
	get_parent().get_parent().get_parent().use_item(item)

func _on_Use_pressed():
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Itens.get_children():
		e.set_focus_mode(2)
	location = "ITENS"
	for i in range(len(GLOBAL.INVENTORY)):
		var node = get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i))
		if node.disabled == false:
			get_node("Panel/HBoxContainer/Itens/ItemSlot" + str(i)).grab_focus()
			break
	#get_node("Panel/HBoxContainer/Itens/ItemSlot0").grab_focus()

func _process(delta):
	update_itens(GLOBAL.INVENTORY)
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
	location == "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()
