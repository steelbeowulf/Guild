extends Node

const DEFAULT_BATTLE_BACKGROUND = "res://assets/sprites/backgrounds/forest2.png"
const DEFAULT_BATTLE_MUSIC = "BATTLE_THEME"

const BATTLE_CLASS = preload("res://code/classes/events/battle.gd")

const NAME = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z"
]

# Dictionary: { enemy_index: count on current battle }
var count_in_battle = {}

# encounter variables
onready var encounter = []
onready var kill = []
onready var enemies = []
onready var map = null

# Battle variables
onready var battled_enemies = []
onready var background
onready var music = "BATTLE_THEME"
onready var current_battle = null

# Level up variable
onready var leveled_up = []

# Config variables
onready var cursor_default = 0
onready var cursor_opt = ["Reset", "Remember"]
onready var cursor = [0, 1]
onready var cursor_index = 0

onready var animation_speed = 1
onready var speed_opt = ["Slow", "Normal", "Fast"]
onready var speed = [0.5, 1, 2]
onready var speed_index = 0


# Sets the possible pool of enemies to draw from and the map
func init(enemies_arg: Array, map_arg: Array):
	enemies = enemies_arg
	map = map_arg
	LOCAL.TRANSITION = -1
	print("[BATTLE INIT] current map: " + str(LOCAL.get_map()))
	background = load("res://assets/sprites/backgrounds/forest2.png")


######### CONFIG FUCTIONS #########
func set_battle_speed(index: int):
	speed_index = index
	animation_speed = speed[index]


func set_cursor_default(index: int):
	cursor_index = index
	cursor_default = cursor[index]


func get_speed():
	return speed_index


func get_cursor():
	return cursor_index


func get_cursor_opts():
	return cursor_opt


func get_speed_opts():
	return speed_opt


###### ENEMY ENCOUNTER FUNCTIONS #####


# Updates the encounter and kill variables based on
# enemy visibility
func _encounter_management(value: int, index: int, name: String):
	if LOCAL.entering_battle:
		return
	print("[BM] encounter Management " + str(value) + ", " + name)
	if value:
		encounter.append(index)
		kill.append(name)
	else:
		encounter.erase(index)
		kill.erase(name)


# Generates a random encounter from the enemies
# on on the current area
func generate_enemies():
	var new_enemies = []

	# Randomizes the number of monsters on the encounter
	# TODO: uncomment this (it was tiring testing things with 4-5 enemies every battle)
	var total = 1  #+ (randi() % 4)

	# Checks if it's the demo boss
	# TODO: Make this not hardcoded
	if encounter:
		if encounter[0] == 11:
			var max_hp = GLOBAL.ENEMIES[11].get_max_health()
			var num_defeated = GLOBAL.get_event_status("eyeballs_defeated")
			GLOBAL.ENEMIES[11].set_stats(0, max_hp - max_hp * 0.1 * num_defeated)
			total = 0
			GLOBAL.WIN = true
		elif encounter[0] == 9:
			total = 4
		elif encounter[0] == 10:
			var num_defeated = GLOBAL.get_event_status("eyeballs_defeated")
			GLOBAL.set_event_status("eyeballs_defeated", num_defeated + 1)
			total = 0

	# Sets enemies on the encounter as dead on the map
	# regardless if player wins (if they lose, it's a game over)
	for k in kill:
		print("[BM] " + str(k) + " is going to die")
		map.get_node("enemies/" + str(k)).dead = true

	map.update_objects_position()
	kill = []

	# Fills the enemy list from the encounter list (monsters the player
	# see on the battlefield) and generates random ones if there's not enough
	var current = 0
	print("[BM] Creating encounter")
	print(encounter)
	encounter.shuffle()
	while current <= total:
		if encounter:
			new_enemies.append(encounter[0])
			#print("OLD: "+LOCAL.ENEMIES[encounter[0]].get_name())
			#new_enemies.append(LOCAL.ENEMIES[encounter[0]].duplicate())
			#print(LOCAL.ENEMIES[encounter.pop_front()].get_name())
		else:
			var enemy_index = 1 + (randi() % (len(enemies) - 2))
			new_enemies.append(enemy_index)
			#print("NEW: "+enemies[enemy_index].get_name())
			#new_enemies.append(enemies[enemy_index].duplicate())
		current += 1

	encounter = []
	# Returns encounter
	return new_enemies


###### BATTLE MANAGEMENT FUNCTIONS #####

func reset_count_in_battle():
	count_in_battle = {}


func get_next_name_in_battle(index: int) -> String:
	var enemy = LOCAL.get_enemy(index)
	if count_in_battle.has(index):
		count_in_battle[index] = count_in_battle[index] + 1
	else:
		count_in_battle[index] = 0
		return enemy.nome
	return enemy.nome + " " + NAME[count_in_battle[index]]


func _load_enemies(enemy_indexs: Array):
	var enemies = []
	enemy_indexs.sort()
	for index in enemy_indexs:
		var enemy = LOCAL.get_enemy(index)
		enemy.nome = get_next_name_in_battle(index)
		enemies.append(enemy)
	return enemies


func initiate_event_battle(battle: Event):
	battled_enemies = battle.get_enemies()
	background = load(battle.get_background())
	music = battle.get_bgm()
	current_battle = battle.duplicate()
	get_tree().change_scene("res://code/battle/battle_screen.tscn")


# Generates enemies and begins the battle
func initiate_battle():
	print("[BATTLE INIT] initiating battle")
	var battle = BATTLE_CLASS.new(
		generate_enemies(), DEFAULT_BATTLE_BACKGROUND, DEFAULT_BATTLE_MUSIC
	)
	current_battle = battle.duplicate()
	battled_enemies = battle.get_enemies()
	get_tree().change_scene("res://code/battle/battle_screen.tscn")


# Finishes a battle and manages EXP, level up and game over
func end_battle(players: Array, enemies: Array, inventory):
	LOCAL.IN_BATTLE = false
	count_in_battle = {}
	var total_exp = 0

	# Calculates total EXP based on the enemies killed
	for e in enemies:
		print("[BM] " + e.get_name())
		if e.is_dead():
			print("is dead")
			total_exp += e.get_xp()

	# Level up alive players and resets status/hate
	var level_up = false
	var death = 0
	for p in players:
		print("[BM] " + p.get_name())
		if not p.is_dead():
			p.remove_all_status()
			p.zero_hate()
			p.reset_hate()
			var levelup_data = p.gain_exp(total_exp)
			if levelup_data[0] > 0:
				level_up = true
			leveled_up.append(levelup_data)
		else:
			leveled_up.append([0, {}])
			death += 1

	GLOBAL.PLAYERS = players
	GLOBAL.INVENTORY = inventory

	# Goes to game over, level up scenes or back to the map
	# depending on the outcome of the battle
	if death == len(players):
		print("[BM] Game over!")
		AUDIO.play_bgm("GAME_OVER_THEME")
		get_tree().change_scene("res://code/battle/post_battle/game_over_screen.tscn")
	elif level_up:
		print("[BM] Someone leveled up")
		get_tree().change_scene("res://code/battle/post_battle/level_up_screen.tscn")
	else:
		print("[BM] Back to the map")
		get_tree().change_scene("res://code/root.tscn")


func on_dialogue_ended():
	get_node("/root/Battle").resume()
	get_node("/root/Battle").emit_signal("event_finished")
