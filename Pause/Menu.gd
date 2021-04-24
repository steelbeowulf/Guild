extends Control

onready var location = "MENU"
onready var x

func _ready():
	for btn in $Panel/All/Right/Options_Panel/Options.get_children():
		btn.connect("focus_entered", self, "_on_Focus_Entered")
	for i in range(4):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.connect("pressed", self, "_on_Player_chosen", [i])
		node.connect("focus_entered", self, "_on_Focus_Entered")

func enter(players):
	location = "MENU"
	x = len(players)
	give_focus()
	for i in range(len(players)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.update_info(players[i])


func _on_Player_chosen(binds):
	AUDIO.play_se("ENTER_MENU")
	if location == "SKILLS":
		get_parent().get_parent().open_skills(binds)
	elif location == "EQUIPS":
		get_parent().get_parent().open_equips(binds)
	else:
		get_parent().get_parent().player_clicked(binds)


func update_info():
	var info = get_node("Panel/All/Right/Info")
	info.get_node("Area/Area_text").set_text(LOCAL.AREA)
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
	print("forço foco no char")
	var options = $Panel/All/Right/Options_Panel/Options.get_children()
	for b in options:
		b.set_focus_mode(0)
	var chars = $Panel/All/Left/Chars.get_children()
	print(chars)
	for c in chars:
		c.set_focus_mode(2)
		c.disabled = false
		for l in c.get_node("Lanes").get_children():
			l.set_focus_mode(0)
	chars[0].grab_focus()


func give_focus():
	print("deu foco")
	var players_avaliable = x
	var options = $Panel/All/Right/Options_Panel/Options.get_children()
	for b in options:
		b.set_focus_mode(2)
		b.disabled = false
	var chars = $Panel/All/Left/Chars.get_children()
	var n = []
	for i in range(players_avaliable):
		n.insert(i, chars[i])
	print(n)
	for c in n:
		c.set_focus_mode(0)
		c.disabled = true
		for l in c.get_node("Lanes").get_children():
			l.set_focus_mode(2)
	options[0].grab_focus()

func change_focus():
	print("troca foco")
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
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().open_inventory()


func _on_Skill_pressed():
	AUDIO.play_se("ENTER_MENU")
	location = "SKILLS"
	change_focus()
	

func _on_Options_pressed():
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().open_options()


func _on_Save_pressed():
	AUDIO.play_se("ENTER_MENU")
	get_parent().get_parent().open_save()


func _on_Status_pressed():
	AUDIO.play_se("ENTER_MENU")
	location = "STATUS"
	get_parent().get_parent().toggle_status()


func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")

func _on_Equip_pressed():
	AUDIO.play_se("ENTER_MENU")
	location = "EQUIPS"
	change_focus()

