extends Control

func enter(players):
	get_node("Panel/All/Right/Options_Panel/Options/Item").grab_focus()
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
		# Needs a portrait
		#node.get_node("Sprite").set_texture(players[i].sprite)

func update_info():
	get_node("Panel/All/Left/Chars/Char1").grab_focus()
	var info = get_node("Panel/All/Right/Info")
	info.get_node("Area/Area_text").set_text(GLOBAL.area)
	info.get_node("Money/Money_text").set_text(format_gold(GLOBAL.gold))
	info.get_node("Playtime/Playtime_text").set_text(format_playtime(GLOBAL.playtime))

func format_gold(money):
	return str(money)+"G"

func format_playtime(T):
	print("aki o hotstio")
	print(T)
	var hours = floor(T / 3600);
	var minutes = floor(T / 60) - hours*60;
	var seconds = (T % 60);
	return str(hours)+"h"+str(minutes)+"m"+str(seconds)+"s" 

func _on_Item_pressed():
	print("pressei item")
	get_tree().change_scene("Itens.tscn")


func _on_Skill_pressed():
	print("pressei skill")
	get_tree().change_scene("Skill.tscn")


func _on_Options_pressed():
	pass # Replace with function body.


func _on_Save_pressed():
	get_parent().get_parent().open_save()
