extends Control
onready var equip = null
onready var player = null
onready var identification
onready var location = "OUTSIDE" #this doesnt work yet, pressing esc on the menu opens the item menu

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
	print("[EQUIP] just entered "+str(id))
	player = GLOBAL.PLAYERS[id]
	location = "SUBMENU"
#	show_equips(GLOBAL.EQUIPAMENT)


#probably broken because equip currently doesnt support different types
func show_equips(equipaments, type):
	var equipped = get_node("Panel/HBoxContainer/Equips/EquipSlot0")#ponto inicial da lista - precisa implementar players com itens equipados
	equipped.set_text(str(player.get_equipament(type).name))
	equipped.show()
	for i in range(len(equipaments)):
		var node = get_node("Panel/HBoxContainer/Equips/EquipSlot" + str(i+1))
		node.set_text(str(equipaments[i][type].nome))
		node.show()
		if equipaments[i][type].classe != player.classe:
			node.disabled = true


#not done yet
func _on_Equip_selected(id, type):
	AUDIO.play_se("ENTER_MENU")
	equip = player.get_equipament(type)
	use_equip(equip)

#not done yet
func _on_Equip_hover(id, type):
	AUDIO.play_se("MOVE_MENU")
	equip = player.get_equipament(type)
	set_description(equip)

#not done yet
func set_description(equip_hover):
	print("Set description")
	#print(item.get_name())
	var description = "  "+equip_hover.name+"\n  Type: "+equip_hover
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)

#not done yet
#func use_item(item):
#	AUDIO.play_se("ENTER_MENU")
#	get_parent().get_parent().get_parent().use_item(item)

#not done yet
func _process(delta):
	#if skills:
	#show_equips(equipament, type)
	if Input.is_action_just_pressed("ui_cancel") and location == "WEAPONS":
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "HEAD":
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "BODY":
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "ACESSORY":
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "SUBMENU":
		AUDIO.play_se("EXIT_MENU")
		location = "OUTSIDE"
		get_parent().get_parent().get_parent().return_menu()

#not done yet
func give_focus():
	$Panel/HBoxContainer/Options/Weapon.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Head.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Body.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Acessory1.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Acessory2.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/Head").grab_focus()

#not done yet
func enter():
	give_focus()
	for c in $Panel/HBoxContainer/Equips.get_children():
		c.connect("target_picked", self, "_on_Equip_selected")
		c.connect("target_selected", self, "_on_Equip_hover")
	get_node("Panel/HBoxContainer/Options/Weapon").grab_focus()
	#show_skills(GLOBAL.PLAYERS)

#not done yet
func use_equip(equip):#still not sure on it will be done
	#AUDIO.play_se("ENTER_MENU")
	var aux = player.get_equipament(type)
	player.get_equipament(type) = equip
	equip = aux
	#get_parent().get_parent().get_parent().use_skill(skill, player)
	#for i in range(skills):#The MP spend will be made here instead of on the other menu
	#	if namex == skills[i].name:
	#		player.set_mp(mpleft - skills[i].quantity)
	#		mpleft = player.get_mp()
	#if mpleft < 0:
	#	mpleft = 0

func _on_Back_pressed():
	AUDIO.play_se("EXIT_MENU")
	print(location)
	location == "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()

#not done yet
func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")

func _on_Weapon_pressed():
	location = "WEAPONS"
	show_equips(GLOBAL.EQUIPAMENT, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	get_node("Panel/HBoxContainer/Equips/EquipSlot1").grab_focus()


func _on_Head_pressed():
	location = "HEAD"
	show_equips(GLOBAL.EQUIPAMENT, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	get_node("Panel/HBoxContainer/Equips/EquipSlot1").grab_focus()


func _on_Body_pressed():
	location = "BODY"
	show_equips(GLOBAL.EQUIPAMENT, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	get_node("Panel/HBoxContainer/Equips/EquipSlot1").grab_focus()


func _on_Acessory1_pressed():
	location = "ACESSORY"
	show_equips(GLOBAL.EQUIPAMENT, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	get_node("Panel/HBoxContainer/Equips/EquipSlot1").grab_focus()


func _on_Acessory2_pressed():
	location = "ACESSORY"
	show_equips(GLOBAL.EQUIPAMENT, location)
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(2)
	get_node("Panel/HBoxContainer/Equips/EquipSlot1").grab_focus()
