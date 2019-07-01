extends Node
onready var loader = get_node("/root/LOADER")

func _ready():
	$Start.grab_focus()

func _on_Button_pressed():
	GLOBAL.ALL_SKILLS = loader.load_all_skills()
	GLOBAL.ALL_ITENS = loader.load_all_itens()
	GLOBAL.ALL_ENEMIES = loader.load_all_enemies()
	GLOBAL.INVENTORY = loader.build_inventory()
	GLOBAL.ALL_PLAYERS = loader.players_from_file()
	get_tree().change_scene("res://Overworld/Map.tscn")

func _on_Button2_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")
	
func _on_Button3_pressed():
	get_tree().quit()