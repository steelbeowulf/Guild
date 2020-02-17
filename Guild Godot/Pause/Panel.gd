extends Panel
var x = 0

func _ready():
	for c in $HBoxContainer/Itens.get_children():
		c.connect("target_picked", self, "_on_Item_selected")
	get_node("HBoxContainer/Options/Use").grab_focus()
	show_itens(GLOBAL.INVENTORY)
	

func show_itens(bag):
	for i in range(len(bag)):
		var node = get_node("HBoxContainer/Itens/ItemSlot" + str(i))
		node.set_text(str(bag[i].nome) + " x" + str(bag[i].quantity))
		node.show()
	get_node("HBoxContainer/Options/Use").grab_focus()
	for e in $HBoxContainer/Itens.get_children():
			e.set_focus_mode(0)

func _on_Item_selected(name):
	print("Sou o item " + name)
	#Placeholder until we actually put item funcionality on the game
	for i in range(len(GLOBAL.INVENTORY)):
		if GLOBAL.INVENTORY[i].nome in name:#that doesnt work, usar mega potion ou hi-potion faz usar potion regulares as well
			GLOBAL.INVENTORY[i].quantity -=1
			x = 1



func _on_Use_pressed():
	for e in $HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $HBoxContainer/Itens.get_children():
			e.set_focus_mode(2)
	get_node("HBoxContainer/Itens/ItemSlot0").grab_focus()


func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		$HBoxContainer/Options/Use.set_focus_mode(2)
		$HBoxContainer/Options/Organize.set_focus_mode(2)
		$HBoxContainer/Options/KeyItens.set_focus_mode(2)
		$HBoxContainer/Options/Back.set_focus_mode(2)
		for e in $HBoxContainer/Itens.get_children():
			e.set_focus_mode(0)
		get_node("HBoxContainer/Options/Use").grab_focus()
	#another placeholder until itens can be used in menus
	if x == 1:
		for i in range(len(GLOBAL.INVENTORY)):
			var node = get_node("HBoxContainer/Itens/ItemSlot" + str(i))
			node.set_text(str(GLOBAL.INVENTORY[i].nome) + " x" + str(GLOBAL.INVENTORY[i].quantity))
		x = 0


