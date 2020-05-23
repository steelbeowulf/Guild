extends Control

onready var location = "OUTSIDE"
var recoverHP = 0
var recoverMP = 0
var hp_char = GLOBAL.ALL_PLAYERS[0].stats[0]
var hpmax_char = GLOBAL.ALL_PLAYERS[0].stats[1]
var mp_char = GLOBAL.ALL_PLAYERS[0].stats[2]
var mpmax_char = GLOBAL.ALL_PLAYERS[0].stats[3]
var current_player
var spell_list
onready var identification
onready var spending

func enter(itemx, id):
	identification = id
	location = "TARGETS"
	get_node("Panel/All/Left/Chars/Char0").grab_focus()
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if id == GLOBAL.ALL_PLAYERS[i].id:
			current_player = GLOBAL.ALL_PLAYERS[i]
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.update_info(GLOBAL.ALL_PLAYERS[i])
	spell_list = current_player.get_skills()
	for i in range(len(spell_list)):
		if itemx == spell_list[i].nome:
			actual_skill(spell_list[i])

func give_focus():
	$Panel/All/Left/Chars/Char0.set_focus_mode(2)
	$Panel/All/Left/Chars/Char1.set_focus_mode(2)
	$Panel/All/Left/Chars/Char2.set_focus_mode(2)
	$Panel/All/Left/Chars/Char3.set_focus_mode(2)
	get_node("Panel/All/Left/Chars/Char0").grab_focus()

func actual_skill(skill):
	for i in range(len(skill.effect)):
		if skill.effect[i][0] == 0:
			recoverHP = skill.effect[i][1]
		if skill.effect[i][0] == 2:
			recoverMP = skill.effect[i][1]
	#spend the mp here
	var mp = current_player.get_mp()
	spending = mp - skill.quantity


func _process(delta):
	if Input.is_action_pressed("ui_cancel") and location == "TARGETS":
		get_parent().get_parent().get_parent().back_to_skills(identification)
		queue_free()

func _on_Char0_pressed():
	print("vida anterior do curado: " +str(hp_char))
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if GLOBAL.ALL_PLAYERS[i].id == current_player.id:
			GLOBAL.ALL_PLAYERS[i].id = current_player.id
	current_player.stats[2] = spending
	print("valor curado: " + str(recoverHP))
	print("vida atual do curado: " +str(hp_char))
	GLOBAL.ALL_PLAYERS[0].stats[0] = hp_char
	GLOBAL.ALL_PLAYERS[0].stats[2] = mp_char
	get_parent().get_parent().get_parent().back_to_skills(identification)
	queue_free()

func _on_Char1_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if GLOBAL.ALL_PLAYERS[i].id == current_player.id:
			GLOBAL.ALL_PLAYERS[i].id = current_player.id
	current_player.stats[2] = spending
	print("valor curado: " + str(recoverHP))
	GLOBAL.ALL_PLAYERS[1].stats[0] = hp_char
	GLOBAL.ALL_PLAYERS[1].stats[2] = mp_char
	get_parent().get_parent().get_parent().back_to_skills(identification)
	queue_free()

func _on_Char2_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if GLOBAL.ALL_PLAYERS[i].id == current_player.id:
			GLOBAL.ALL_PLAYERS[i].id = current_player.id
	current_player.stats[2] = spending
	print("valor curado: " + str(recoverHP))
	GLOBAL.ALL_PLAYERS[2].stats[0] = hp_char
	GLOBAL.ALL_PLAYERS[2].stats[2] = mp_char
	get_parent().get_parent().get_parent().back_to_skills(identification)
	queue_free()

func _on_Char3_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if GLOBAL.ALL_PLAYERS[i].id == current_player.id:
			GLOBAL.ALL_PLAYERS[i].id = current_player.id
	current_player.stats[2] = spending
	print("valor curado: " + str(recoverHP))
	GLOBAL.ALL_PLAYERS[3].stats[0] = hp_char
	GLOBAL.ALL_PLAYERS[3].stats[2] = mp_char
	get_parent().get_parent().get_parent().back_to_skills(identification)
	queue_free()
