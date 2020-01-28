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

func enter():
	get_node("Panel/All/Left/Chars/Char1").grab_focus()

func _on_Item_pressed():
	print("Cliquei em itens!")
