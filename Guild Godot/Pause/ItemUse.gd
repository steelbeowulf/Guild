extends Control

var recoverHP = 0
var recoverMP = 0

func enter():
	get_node("Panel/All/Left/Chars/Char0").grab_focus()
	for i in range(len(GLOBAL.ALL_PLAYERS)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.get_node("Name").set_text(GLOBAL.ALL_PLAYERS[i].get_name())
		node.get_node("Level").set_text(str(GLOBAL.ALL_PLAYERS[i].level))
		var tmp = str(GLOBAL.ALL_PLAYERS[i].get_health())+"/"+str(GLOBAL.ALL_PLAYERS[i].get_max_health())
		node.get_node("HP").set_text(tmp)
		tmp = str(GLOBAL.ALL_PLAYERS[i].get_mp())+"/"+str(GLOBAL.ALL_PLAYERS[i].get_max_mp())
		node.get_node("MP").set_text(tmp)
		tmp = str(GLOBAL.ALL_PLAYERS[i].xp)+"/"+str(((18/10)^GLOBAL.ALL_PLAYERS[i].level)*5)
		node.get_node("EXP").set_text(tmp)
		# Needs a portrait
		#node.get_node("Sprite").set_texture(players[i].sprite)

func actual_item(item):
	for i in range(len(item.effect)):
		if item.effect[i][0] == "HP":
			recoverHP = item.effect[i][1]
		if item.effect[i][0] == "MP":
			recoverMP = item.effect[i][1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Char0_pressed():
	GLOBAL.ALL_PLAYERS[0].stats[0] =  GLOBAL.ALL_PLAYERS[0].stats[0]  + recoverHP
	GLOBAL.ALL_PLAYERS[0].stats[2]  =  GLOBAL.ALL_PLAYERS[0].stats[2]  + recoverMP


func _on_Char1_pressed():
	GLOBAL.ALL_PLAYERS[1].stats[0] =  GLOBAL.ALL_PLAYERS[1].stats[0]  + recoverHP
	GLOBAL.ALL_PLAYERS[1].stats[2]  =  GLOBAL.ALL_PLAYERS[1].stats[2]  + recoverMP


func _on_Char2_pressed():
	GLOBAL.ALL_PLAYERS[2].stats[0] =  GLOBAL.ALL_PLAYERS[2].stats[0]  + recoverHP
	GLOBAL.ALL_PLAYERS[2].stats[2]  =  GLOBAL.ALL_PLAYERS[2].stats[2]  + recoverMP


func _on_Char3_pressed():
	GLOBAL.ALL_PLAYERS[3].stats[0] =  GLOBAL.ALL_PLAYERS[3].stats[0]  + recoverHP
	GLOBAL.ALL_PLAYERS[3].stats[2]  =  GLOBAL.ALL_PLAYERS[3].stats[2]  + recoverMP
