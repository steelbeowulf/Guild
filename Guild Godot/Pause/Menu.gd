extends Control

func enter(players):
	give_focus()
	for i in range(len(players)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.update_info(players[i])
		node.connect("pressed", self, "_on_Player_chosen", [i])


func _on_Player_chosen(binds):
	print("Cliquei no player "+str(binds))
	get_parent().get_parent().player_clicked(binds)


func update_info():
	var info = get_node("Panel/All/Right/Info")
	info.get_node("Area/Area_text").set_text(GLOBAL.AREA)
	info.get_node("Money/Money_text").set_text(format_gold(GLOBAL.gold))
	info.get_node("Playtime/Playtime_text").set_text(format_playtime(GLOBAL.playtime))


func format_gold(money):
	return str(money)+"G"


func format_playtime(T):
	var hours = floor(T / 3600)
	var minutes = floor(T / 60) - hours*60
	var seconds = (int(T) % int(60))
	return str(hours)+"h"+str(minutes)+"m"+str(seconds)+"s" 


func force_char_focus():
	var options = $Panel/All/Right/Options_Panel/Options.get_children()
	for b in options:
		b.set_focus_mode(0)
	var chars = $Panel/All/Left/Chars.get_children()
	for c in chars:
		c.set_focus_mode(2)
		c.disabled = false
		for l in c.get_node("Lanes").get_children():
			l.set_focus_mode(0)
	chars[0].grab_focus()


func give_focus():
	var options = $Panel/All/Right/Options_Panel/Options.get_children()
	for b in options:
		b.set_focus_mode(2)
		b.disabled = false
	var chars = $Panel/All/Left/Chars.get_children()
	for c in chars:
		c.set_focus_mode(0)
		c.disabled = true
		for l in c.get_node("Lanes").get_children():
			l.set_focus_mode(2)
	options[0].grab_focus()

func change_focus():
	var options = $Panel/All/Right/Options_Panel/Options.get_children()
	for b in options:
		b.set_focus_mode(0)
		b.disabled = true
	var chars = $Panel/All/Left/Chars.get_children()
	for c in chars:
		c.set_focus_mode(2)
		c.disabled = false
		for l in c.get_node("Lanes").get_children():
			l.set_focus_mode(0)
	chars[0].grab_focus()

func _on_Item_pressed():
	get_parent().get_parent().open_inventory()


func _on_Skill_pressed():
	change_focus()
	

func _on_Char0_pressed():
	var name = get_node("Panel/All/Left/Chars/Char0").text
	var id
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if name == GLOBAL.ALL_PLAYERS[i].nome:
			id = GLOBAL.ALL_PLAYERS[i].id
	get_parent().get_parent().open_skills(id)

func _on_Char1_pressed():
	var name = get_node("Panel/All/Left/Chars/Char1").text
	var id
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if name == GLOBAL.ALL_PLAYERS[i].nome:
			id = GLOBAL.ALL_PLAYERS[i].id
	get_parent().get_parent().open_skills(id)


func _on_Char2_pressed():
	var name = get_node("Panel/All/Left/Chars/Char2").text
	var id
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if name == GLOBAL.ALL_PLAYERS[i].nome:
			id = GLOBAL.ALL_PLAYERS[i].id
	get_parent().get_parent().open_skills(id)


func _on_Char3_pressed():
	var name = get_node("Panel/All/Left/Chars/Char3").text
	var id
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		if name == GLOBAL.ALL_PLAYERS[i].nome:
			id = GLOBAL.ALL_PLAYERS[i].id
	get_parent().get_parent().open_skills(id)

func _on_Options_pressed():
	pass # Replace with function body.


func _on_Save_pressed():
	get_parent().get_parent().open_save()


func _on_Status_pressed():
	get_parent().get_parent().toggle_status()


