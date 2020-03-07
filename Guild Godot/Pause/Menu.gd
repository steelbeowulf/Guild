extends Control

func enter(players):
	give_focus()
	for i in range(len(players)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.get_node("Name").set_text(players[i].get_name())
		node.get_node("Level").set_text(str(players[i].level))
		var tmp = str(players[i].get_health())+"/"+str(players[i].get_max_health())
		node.get_node("HP").set_text(tmp)
		tmp = str(players[i].get_mp())+"/"+str(players[i].get_max_mp())
		node.get_node("MP").set_text(tmp)
		tmp = str(players[i].xp)+"/"+str(((18/10)^players[i].level)*5)
		node.get_node("EXP").set_text(tmp)
		node.connect("pressed", self, "_on_Player_chosen", [i])
		# Needs a portrait
		#node.get_node("Sprite").set_texture(players[i].sprite)


func _on_Player_chosen(binds):
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
	chars[0].grab_focus()


func give_focus():
	var options = $Panel/All/Right/Options_Panel/Options.get_children()
	for b in options:
		b.set_focus_mode(2)
	var chars = $Panel/All/Left/Chars.get_children()
	for c in chars:
		c.set_focus_mode(0)
	options[0].grab_focus()


func _on_Item_pressed():
	get_parent().get_parent().open_inventory()


func _on_Skill_pressed():
	pass # Replace with function body.


func _on_Options_pressed():
	pass # Replace with function body.


func _on_Save_pressed():
	get_parent().get_parent().open_save()


func _on_Status_pressed():
	get_parent().get_parent().toggle_status()
