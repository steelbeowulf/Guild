extends Control
var x = 0
onready var location = "OUTSIDE" #this doesnt work yet, pressing esc on the menu opens the item menu

func _ready():
	give_focus()
	for c in $Panel/HBoxContainer/Itens.get_children():
		c.connect("target_picked", self, "_on_Skill_selected")
	get_node("Panel/HBoxContainer/Options/Skill Type 1").grab_focus()

func just_entered():
	location = "SUBMENU"

func show_skills(player):
	var skills = player.get_skills()
	var mpleft = player.get_mp()
	for i in range(len(skills)):
		var node = get_node("Panel/HBoxContainer/Skills/SkillSlot" + str(i))
		node.set_text(str(skills[i].nome) + " - " + str(skills[i].quantity) + "mp")
		node.show()
		if mpleft < skills[i].quantity:
			node.hide() #Hide por enquanto, depois vai ser so impossibilitado de usar, mas mostrando que a skill existe
		get_node("Panel/HBoxContainer/Options/Skill Type 1").grab_focus()
		for e in $Panel/HBoxContainer/Skills.get_children():
			e.set_focus_mode(0)

func update_skills(player):#Ainda mantendo a solução temporaria de esconder o node quando nao houver mais mana para as skills
	for i in range(len(player)):#por hora nao funciona, arrumar depois
		var node = get_node("Panel/HBoxContainer/Skills/SkillSlot" + str(i))
		var mpleft = player.get_mp()
		if mpleft < player[i].quantity:
			node.hide()

func _on_Skill_selected(name):
	var namearray = name.split(" - ", true, 1)
	var nome = namearray[0]
	use_skill(nome)

func use_skill(namex):
	get_parent().get_parent().use_skill(namex)

func _on_Skill_Type_1_pressed():
	for e in $Panel/HBoxContainer/Options.get_children():
		e.set_focus_mode(0)
	for e in $Panel/HBoxContainer/Skills.get_children():
		e.set_focus_mode(2)
	location = "SKILLS"
	get_node("Panel/HBoxContainer/Skills/SkillSlot1").grab_focus()

func _process(delta):
	#update_skills(player)
	if Input.is_action_pressed("ui_cancel") and location == "SKIILS":
		location == "SUBMENU"
		give_focus()
	elif Input.is_action_pressed("ui_cancel") and location == "SUBMENU":
		location == "OUTSIDE"
		get_parent().get_parent().open_menu()


func give_focus():
	$Panel/HBoxContainer/Options/Skill_Type_1.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Skill_Type_2.set_focus_mode(2)
	$Panel/HBoxContainer/Options/Back.set_focus_mode(2)
	for e in $Panel/HBoxContainer/Skills.get_children():
		e.set_focus_mode(0)
	get_node("Panel/HBoxContainer/Options/Skill Type 1").grab_focus()
