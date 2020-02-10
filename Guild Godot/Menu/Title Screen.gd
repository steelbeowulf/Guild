extends Node
onready var loader = get_node("/root/LOADER")

func _ready():
	AUDIO.initSound()
	$New.grab_focus()

func _on_New_pressed():
	GLOBAL.ALL_SKILLS = loader.load_all_skills()
	GLOBAL.ALL_ITENS = loader.load_all_itens()
	GLOBAL.ALL_ENEMIES = loader.load_all_enemies()
	GLOBAL.INVENTORY = loader.build_inventory()
	GLOBAL.ALL_PLAYERS = loader.players_from_file()
	GLOBAL.reload_state()
	get_tree().change_scene("res://Root.tscn")


func _on_Load_pressed():
	print("AYE")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")
