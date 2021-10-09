extends Control
onready var player = null
onready var current_equip = null
onready var equips = []
onready var location = "OUTSIDE"  #this doesnt work yet, pressing esc on the menu opens the item menu


func _ready():
	give_focus()
	var itemNodes = $Panel/HBoxContainer/Equips.get_children()
	for i in range(len(itemNodes)):
		var c = itemNodes[i]
		c.connect("target_picked", self, "_on_Equip_selected", [i])
		c.connect("target_selected", self, "_on_Equip_hover", [i])
	for btn in $Panel/HBoxContainer/Options.get_children():
		btn.connect("focus_entered", self, "_on_Focus_Entered")
	get_node("Panel/HBoxContainer/Options/Weapon").grab_focus()
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)


func just_entered(id):
	print("[EQUIP] just entered " + str(id))
	player = GLOBAL.PLAYERS[id]
	location = "SUBMENU"


func reset_equips():
	equips = []
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.hide()


func show_equips(equipaments, type):
	reset_equips()
	reset_info()
	# Ponto inicial da lista
	var equipped = get_node("Panel/HBoxContainer/Equips/EquipSlot0")
	equipped.disabled = true
	equipped.set_focus_mode(0)
	var player_equip = player.get_equip(type)
	var player_equip_name = "NONE"

	# Player has item equiped on this slot: show it
	if player_equip:
		equipped.disabled = false
		equipped.set_focus_mode(2)
		player_equip_name = player_equip.get_name()
		current_equip = player_equip
	equipped.set_text("EQUIPPED: " + player_equip_name)
	equipped.show()

	# Iterate through equip_inventory and populate list
	equips = [player_equip]
	var i = 1
	for j in range(len(equipaments)):
		var equip = equipaments[j]
		if equip.quantity > 0 and equip.location == type and player_equip_name != equip.get_name():
			var node = get_node("Panel/HBoxContainer/Equips/EquipSlot" + str(i))
			i += 1
			equips.append(equip)
			node.set_text(str(equipaments[j].get_name()))
			node.show()
			node.disabled = false
			# Disable if wrong job
			if equipaments[j].job != player.get_job():
				node.disabled = true


# Get first equippable item from equip list
# Avoids giving focus to wrong job itens
func get_first_equippable():
	for i in range(len(equips)):
		if equips[i] != null and equips[i].job == player.get_job():
			return get_node("Panel/HBoxContainer/Equips/EquipSlot" + str(i))


# Equip item with id
func _on_Equip_selected(id):
	AUDIO.play_se("ENTER_MENU")
	use_equip(equips[id])


func _on_Equip_hover(id):
	AUDIO.play_se("MOVE_MENU")
	set_description(equips[id])
	$Panel/HBoxContainer/Options/Info/Comparison.init(current_equip, equips[id])


# Reset info panel
func reset_info():
	$Panel/HBoxContainer/Options/Info/Comparison.zero()
	$Panel/HBoxContainer/Options/Info/Description.set_text("")


# Sets description
func set_description(equip_hover):
	print("Set description")
	var description = "  " + equip_hover.name + "\n  Type: " + equip_hover.type
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)


# TODO: Arrumar location (minuscula? maiuscula? idk)
func _process(delta):
	if (
		Input.is_action_just_pressed("ui_cancel")
		and location in ["WEAPON", "HEAD", "BODY", "ACCESSORY1", "ACCESSORY2"]
	):
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "SUBMENU":
		AUDIO.play_se("EXIT_MENU")
		location = "MENU"
		get_parent().get_parent().get_parent().return_menu()


func give_focus():
	print("Giving focus...")
	$Panel/HBoxContainer/Options/Weapon.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Head.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Body.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Accessory1.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Accessory2.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(0)
		e.hide()
	get_node("Panel/HBoxContainer/Options/Weapon").grab_focus()
	reset_info()


func enter():
	give_focus()
	get_node("Panel/HBoxContainer/Options/Weapon").grab_focus()


# Can't unequip for now
func use_equip(equip):
	AUDIO.play_se("ENTER_MENU")
	if location == "ACCESSORY1":
		player.equip(equip, 3)
	elif location == "ACCESSORY2":
		player.equip(equip, 4)
	else:
		player.equip(equip)
	show_equips(GLOBAL.EQUIP_INVENTORY, location)


func _on_Back_pressed():
	AUDIO.play_se("EXIT_MENU")
	print(location)
	location == "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()


#not done yet
func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")


func _on_Weapon_pressed():
	location = "WEAPON"
	show_equips(GLOBAL.EQUIP_INVENTORY, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	var first = get_first_equippable()
	if first:
		first.grab_focus()


func _on_Head_pressed():
	location = "HEAD"
	show_equips(GLOBAL.EQUIP_INVENTORY, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	var first = get_first_equippable()
	if first:
		first.grab_focus()


func _on_Body_pressed():
	location = "BODY"
	show_equips(GLOBAL.EQUIP_INVENTORY, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	var first = get_first_equippable()
	if first:
		first.grab_focus()


func _on_Acessory1_pressed():
	location = "ACCESSORY1"
	show_equips(GLOBAL.EQUIP_INVENTORY, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	var first = get_first_equippable()
	if first:
		first.grab_focus()


func _on_Acessory2_pressed():
	location = "ACCESSORY2"
	show_equips(GLOBAL.EQUIP_INVENTORY, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	var first = get_first_equippable()
	if first:
		first.grab_focus()
