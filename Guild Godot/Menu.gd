extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print("Eestou no ŕpcess do menu!")

func enter(players):
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
	get_node("Panel/All/Left/Chars/Char1").grab_focus()

func _on_Item_pressed():
	print("Cliquei em itens!")
