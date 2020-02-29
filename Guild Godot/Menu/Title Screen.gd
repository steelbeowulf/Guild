extends Node

onready var loader = get_node("/root/LOADER")

signal slot_chosen

func _ready():
	AUDIO.initSound()
	$New.grab_focus()
	var tmp = 0
	for c in get_node("Load_Screen/Save Slots").get_children():
		c.connect("button_down", self, "_on_Slot_chosen", [tmp])
		tmp += 1

func _on_New_pressed():
	GLOBAL.ALL_SKILLS = loader.load_all_skills()
	GLOBAL.ALL_ITENS = loader.load_all_itens()
	GLOBAL.ALL_ENEMIES = loader.load_all_enemies()
	GLOBAL.INVENTORY = loader.load_inventory(-1)
	GLOBAL.ALL_PLAYERS = loader.load_players(-1)
	GLOBAL.reload_state()
	get_tree().change_scene("res://Root.tscn")
	#Use this to get to the item menu for it to work
	#get_tree().change_scene("res://Pause/Itens.tscn")


func _on_Load_pressed():
	$"Load_Screen/Save Slots".enable_focus(false)
	$Load_Screen.show()
	GLOBAL.ALL_SKILLS = loader.load_all_skills()
	GLOBAL.ALL_ITENS = loader.load_all_itens()
	GLOBAL.ALL_ENEMIES = loader.load_all_enemies()

func _on_Slot_chosen(slot):
	GLOBAL.INVENTORY = loader.load_inventory(slot)
	GLOBAL.ALL_PLAYERS = loader.load_players(slot)
	GLOBAL.load_game(slot)
	get_tree().change_scene("res://Root.tscn")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$Load_Screen.hide()
		$"Load_Screen/Save Slots".remove_focus()
		$New.grab_focus()

func _on_Exit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")
