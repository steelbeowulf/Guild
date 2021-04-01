extends Control
onready var equip = null
onready var player = null
onready var identification
onready var equips
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
	get_node("Panel/HBoxContainer/Options/Head").grab_focus()

func just_entered(id):
	print("[SKILL] just entered "+str(id))
	player = GLOBAL.PLAYERS[id]
	location = "SUBMENU"
	show_equips()

func show_equips():
	equips = player.get_equips()
	for i in range(len(equips)):
		var node = get_node("Panel/HBoxContainer/Equips/SkillSlot" + str(i))
		if equips[i] != null:
			node.set_text(str(equips[i].get_name()) + " - " + str(equips[i].quantity) + "mp")
		else:
			node.set_text("NONE")
		node.show()
		get_node("Panel/HBoxContainer/Options/Head").grab_focus()
		for e in $Panel/HBoxContainer/Equips.get_children():
			e.set_focus_mode(0)


func update_equips(equips):#Ainda mantendo a solução temporaria de esconder o node quando nao houver mais mana para as equips
	if !equips:
		return
	for i in range(len(equips)):
		var node = get_node("Panel/HBoxContainer/equips/equipslot" + str(i))

func _on_Equip_selected(id):
	AUDIO.play_se("ENTER_MENU")
	equip = player.get_equips()[id]
	var nome = equip.get_name()
	print("SELECTED "+str(nome))
	#set_description(item)
	use_skill(equip)

func _on_Equip_hover(id):
	AUDIO.play_se("MOVE_MENU")
	equip = player.get_equips()[id]
	var nome = equip.get_name()
	print("SELECTED "+str(equip))
	set_description(equip)

func set_description(equip):
	print("Set description")
	#print(item.get_name())
	var description = "  "+equip.get_name()+"\n  Type: "+equip.get_type()+"\n  Targets: "+equip.get_target()
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)

func use_item(item):
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().get_parent().use_item(item)

func _process(delta):
	#if equips:
	update_equips(equips)
	if Input.is_action_just_pressed("ui_cancel") and location == "equips":
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "SUBMENU":
		AUDIO.play_se("EXIT_MENU")
		location = "OUTSIDE"
		get_parent().get_parent().get_parent().return_menu()

func give_focus():
	for c in $Panel/HBoxContainer/Options.get_children():
		c.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Equips.get_children():
		e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/Head").grab_focus()


func enter():
	give_focus()
	for c in $Panel/HBoxContainer/Equips.get_children():
		c.connect("target_picked", self, "_on_Skill_selected")
		c.connect("target_selected", self, "_on_Skill_hover")
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()
	#show_equips(GLOBAL.PLAYERS)

func use_skill(equip):
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().get_parent().use_skill(equip, player)
	#for i in range(equips):#The MP spend will be made here instead of on the other menu
	#	if namex == equips[i].name:
	#		player.set_mp(mpleft - equips[i].quantity)
	#		mpleft = player.get_mp()
	#if mpleft < 0:
	#	mpleft = 0

func _on_Skill_Type_1_pressed():
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/equips.get_children():
		e.set_focus_mode(2)
	location = "equips"
	get_node("Panel/HBoxContainer/equips/equipslot0").grab_focus()

func _on_Back_pressed():
	AUDIO.play_se("EXIT_MENU")
	print(location)
	location == "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()

func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")