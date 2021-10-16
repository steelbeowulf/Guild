extends Control
onready var skill = null
onready var player = null
onready var identification
onready var skills
onready var mpleft
onready var location = "OUTSIDE"  #this doesnt work yet, pressing esc on the menu opens the item menu


func _ready():
	give_focus()
	var itemNodes = $Panel/HBoxContainer/Skills.get_children()
	for i in range(len(itemNodes)):
		var c = itemNodes[i]
		c.connect("target_picked", self, "_on_Skill_selected", [i])
		c.connect("target_selected", self, "_on_Skill_hover", [i])
	for btn in $Panel/HBoxContainer/Options.get_children():
		btn.connect("focus_entered", self, "_on_Focus_Entered")
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()


func just_entered(id):
	print("[SKILL] just entered " + str(id))
	player = GLOBAL.get_player(id)
	location = "SUBMENU"
	show_equips()


#not done yet
func show_equips():
	skills = player.get_skills()
	mpleft = player.get_mp()
	for i in range(len(skills)):
		var node = get_node("Panel/HBoxContainer/Skills/SkillSlot" + str(i))
		node.set_text(str(skills[i].name) + " - " + str(skills[i].quantity) + "mp")
		node.show()
		if mpleft < skills[i].quantity:
			node.disabled = true
			#node.hide() #Hide por enquanto, depois vai ser so impossibilitado de usar, mas mostrando que a skill existe
		elif skills[i].type == "OFFENSE":
			node.disabled = true
		get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()
		for e in $Panel/HBoxContainer/Skills.get_children():
			e.set_focus_mode(0)


#not done yet
func update_skills(skills):  #Ainda mantendo a solução temporaria de esconder o node quando nao houver mais mana para as skills
	if !skills:
		return
	for i in range(len(skills)):
		var node = get_node("Panel/HBoxContainer/Skills/SkillSlot" + str(i))
		mpleft = player.get_mp()
		if mpleft < skills[i].quantity:
			node.disabled = true
			#node.hide()


#not done yet
func _on_Skill_selected(id):
	AUDIO.play_se("ENTER_MENU")
	skill = player.get_skills()[id]
	var name = skill.get_name()
	print("SELECTED " + str(name))
	#set_description(item)
	use_skill(skill)


#not done yet
func _on_Skill_hover(id):
	AUDIO.play_se("MOVE_MENU")
	skill = player.get_skills()[id]
	var name = skill.get_name()
	print("SELECTED " + str(skill))
	set_description(skill)


#not done yet
func set_description(skill):
	print("Set description")
	#print(item.get_name())
	var description = (
		"  "
		+ skill.get_name()
		+ "\n  Type: "
		+ skill.get_type()
		+ "\n  Targets: "
		+ skill.get_target()
	)
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)


#not done yet
func use_item(item):
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().get_parent().use_item(item)


#not done yet
func _process(delta):
	#if skills:
	update_skills(skills)
	if Input.is_action_just_pressed("ui_cancel") and location == "SKILLS":
		AUDIO.play_se("EXIT_MENU")
		location = "SUBMENU"
		give_focus()
	elif Input.is_action_just_pressed("ui_cancel") and location == "SUBMENU":
		AUDIO.play_se("EXIT_MENU")
		location = "OUTSIDE"
		get_parent().get_parent().get_parent().return_menu()


#not done yet
func give_focus():
	$Panel/HBoxContainer/Options/SkillType1.set_focus_mode(2)
	$Panel/HBoxContainer/Options/SkillType2.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Skills.get_children():
		e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()


#not done yet
func enter():
	give_focus()
	for c in $Panel/HBoxContainer/Skills.get_children():
		c.connect("target_picked", self, "_on_Skill_selected")
		c.connect("target_selected", self, "_on_Skill_hover")
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()
	#show_skills(GLOBAL.players)


#not done yet
func use_skill(skill):
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().get_parent().use_skill(skill, player)
	#for i in range(skills):#The MP spend will be made here instead of on the other menu
	#	if namex == skills[i].name:
	#		player.set_mp(mpleft - skills[i].quantity)
	#		mpleft = player.get_mp()
	#if mpleft < 0:
	#	mpleft = 0


#not done yet
func _on_Skill_Type_1_pressed():
	AUDIO.play_se("ENTER_MENU")
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Skills.get_children():
		e.set_focus_mode(2)
	location = "SKILLS"
	get_node("Panel/HBoxContainer/Skills/SkillSlot0").grab_focus()


#not done yet
func _on_Back_pressed():
	AUDIO.play_se("EXIT_MENU")
	print(location)
	location == "OUTSIDE"
	get_parent().get_parent().get_parent().return_menu()


#not done yet
func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")
