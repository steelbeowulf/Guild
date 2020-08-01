extends Control
onready var skill = null
onready var player = null
onready var identification
#onready var player
onready var skills
onready var mpleft
onready var location = "OUTSIDE" #this doesnt work yet, pressing esc on the menu opens the item menu

func _ready():
	give_focus()
	var itemNodes = $Panel/HBoxContainer/Skills.get_children()
	for i in range(len(itemNodes)):
		var c = itemNodes[i]
		c.connect("target_picked", self, "_on_Skill_selected", [i])
		c.connect("target_selected", self, "_on_Skill_hover", [i])
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()

func just_entered(id):
	print("[SKILL] just entered "+str(id))
	player = GLOBAL.PLAYERS[id]
	location = "SUBMENU"
	show_skills()

func show_skills():
	skills = player.get_skills()
	mpleft = player.get_mp()
	for i in range(len(skills)):
		var node = get_node("Panel/HBoxContainer/Skills/SkillSlot" + str(i))
		node.set_text(str(skills[i].nome) + " - " + str(skills[i].quantity) + "mp")
		node.show()
		if mpleft < skills[i].quantity:
			node.disabled = true
			#node.hide() #Hide por enquanto, depois vai ser so impossibilitado de usar, mas mostrando que a skill existe
		get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()
		for e in $Panel/HBoxContainer/Skills.get_children():
			e.set_focus_mode(0)

func update_skills(skills):#Ainda mantendo a solução temporaria de esconder o node quando nao houver mais mana para as skills
	if !skills:
		return
	for i in range(len(skills)):
		var node = get_node("Panel/HBoxContainer/Skills/SkillSlot" + str(i))
		mpleft = player.get_mp()
		if mpleft < skills[i].quantity:
			node.disabled = true
			#node.hide()

func _on_Skill_selected(id):
	skill = player.get_skills()[id]
	var nome = skill.get_name()
	print("SELECTED "+str(nome))
	#set_description(item)
	use_skill(skill)

func _on_Skill_hover(id):
	skill = player.get_skills()[id]
	var nome = skill.get_name()
	print("SELECTED "+str(skill))
	set_description(skill)

func set_description(skill):
	print("Set description")
	#print(item.get_name())
	var description = "  "+skill.get_name()+"\n  Type: "+skill.get_type()+"\n  Targets: "+skill.get_target()
	$Panel/HBoxContainer/Options/Info/Description.set_text(description)

func use_item(item):
	get_parent().get_parent().get_parent().use_item(item)

func _process(delta):
	#if skills:
	update_skills(skills)
	if Input.is_action_pressed("ui_cancel") and location == "SKIILS":
		location == "SUBMENU"
		give_focus()
	elif Input.is_action_pressed("ui_cancel") and location == "SUBMENU":
		location == "OUTSIDE"
		get_parent().get_parent().open_menu()

func give_focus():
	$Panel/HBoxContainer/Options/SkillType1.set_focus_mode(2)
	$Panel/HBoxContainer/Options/SkillType2.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Skills.get_children():
		e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()


func enter():
	give_focus()
	for c in $Panel/HBoxContainer/Skills.get_children():
		c.connect("target_picked", self, "_on_Skill_selected")
		c.connect("target_selected", self, "_on_Skill_hover")
	get_node("Panel/HBoxContainer/Options/SkillType1").grab_focus()
	#show_skills(GLOBAL.PLAYERS)

func use_skill(skill):
	get_parent().get_parent().get_parent().use_skill(skill, player)
	#for i in range(skills):#The MP spend will be made here instead of on the other menu
	#	if namex == skills[i].name:
	#		player.set_mp(mpleft - skills[i].quantity)
	#		mpleft = player.get_mp()
	#if mpleft < 0:
	#	mpleft = 0

func _on_Skill_Type_1_pressed():
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Skills.get_children():
		e.set_focus_mode(2)
	location = "SKILLS"
	get_node("Panel/HBoxContainer/Skills/SkillSlot1").grab_focus()


