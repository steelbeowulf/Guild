extends Node

# Encounter variables
onready var Encounter = []
onready var Kill = []
onready var Enemies = []
onready var Map = null

# Battle variables
onready var Battled_Enemies = []
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
func init(enemies_arg, map_arg):
	Enemies = enemies_arg
	Map = map_arg
	LOCAL.TRANSITION = -1
	print("[BATTLE INIT] current map: " + str(LOCAL.get_map()))
	background = load("res://assets/sprites/backgrounds/forest2.png")


######### CONFIG FUCTIONS #########
func set_battle_speed(ID):
	speed_index = ID
	animation_speed = speed[ID]


func set_cursor_default(ID):
	cursor_index = ID
	cursor_default = cursor[ID]


func get_speed():
	return speed_index


func get_cursor():
	return cursor_index


func get_cursor_opts():
	return cursor_opt


func get_speed_opts():
	return speed_opt


###### ENEMY ENCOUNTER FUNCTIONS #####


# Updates the Encounter and Kill variables based on
# enemy visibility
func _encounter_management(value, id, name):
	if LOCAL.entering_battle:
		return
	print("[BM] Encounter Management " + str(value) + ", " + name)
	if value:
		Encounter.append(id)
		Kill.append(name)
	else:
		Encounter.erase(id)
		Kill.erase(name)


# Generates a random encounter from the enemies
# on on the current area
func generate_enemies():
	var newEnemy = []

	# Randomizes the number of monsters on the encounter
	# TODO: uncomment this (it was tiring testing things with 4-5 enemies every battle)
	var total = 1  #+ (randi() % 4)

	# Checks if it's the demo boss
	# TODO: Make this not hardcoded
	if Encounter:
		if Encounter[0] == 11:
			var max_hp = GLOBAL.ENEMIES[11].get_max_health()
			var num_defeated = GLOBAL.get_event_status("eyeballs_defeated")
			GLOBAL.ENEMIES[11].set_stats(0, max_hp - max_hp * 0.1 * num_defeated)
			total = 0
			GLOBAL.WIN = true
		elif Encounter[0] == 9:
			total = 4
		elif Encounter[0] == 10:
			var num_defeated = GLOBAL.get_event_status("eyeballs_defeated")
			GLOBAL.set_event_status("eyeballs_defeated", num_defeated + 1)
			total = 0

	# Sets enemies on the encounter as dead on the map
	# regardless if player wins (if they lose, it's a game over)
	for k in Kill:
		print("[BM] " + str(k) + " is going to die")
		Map.get_node("Enemies/" + str(k)).dead = true

	Map.update_objects_position()
	Kill = []

	# Fills the enemy list from the encounter list (monsters the player
	# see on the battlefield) and generates random ones if there's not enough
	var current = 0
	print("[BM] Creating encounter")
	print(Encounter)
	Encounter.shuffle()
	while current <= total:
		if Encounter:
			newEnemy.append(Encounter[0])
			#print("OLD: "+LOCAL.ENEMIES[Encounter[0]].get_name())
			#newEnemy.append(LOCAL.ENEMIES[Encounter[0]]._duplicate())
			#print(LOCAL.ENEMIES[Encounter.pop_front()].get_name())
		else:
			var enemy_id = 1 + (randi() % (len(Enemies) - 2))
			newEnemy.append(enemy_id)
			#print("NEW: "+Enemies[enemy_id].get_name())
			#newEnemy.append(Enemies[enemy_id]._duplicate())
		current += 1

	Encounter = []
	# Returns encounter
	return newEnemy


###### BATTLE MANAGEMENT FUNCTIONS #####

const DEFAULT_BATTLE_BACKGROUND = "res://assets/sprites/backgrounds/forest2.png"
const DEFAULT_BATTLE_MUSIC = "BATTLE_THEME"

var BATTLE_CLASS = load("res://code/classes/events/battle.gd")

var NAME = [
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

# Dictionary: { enemy_id: count on current battle }
var COUNT_IN_BATTLE = {}


func reset_count_in_battle():
	COUNT_IN_BATTLE = {}


func get_next_name_in_battle(id: int) -> String:
	var enemy = LOCAL.get_enemy(id)
	if COUNT_IN_BATTLE.has(id):
		COUNT_IN_BATTLE[id] = COUNT_IN_BATTLE[id] + 1
	else:
		COUNT_IN_BATTLE[id] = 0
		return enemy.nome
	return enemy.nome + " " + NAME[COUNT_IN_BATTLE[id]]


func _load_enemies(enemy_ids: Array):
	var enemies = []
	enemy_ids.sort()
	for id in enemy_ids:
		var enemy = LOCAL.get_enemy(id)
		enemy.nome = get_next_name_in_battle(id)
		enemies.append(enemy)
	return enemies


func initiate_event_battle(battle: Event):
	Battled_Enemies = battle.get_enemies()
	background = load(battle.get_background())
	music = battle.get_bgm()
	current_battle = battle._duplicate()
	get_tree().change_scene("res://code/battle/battle_screen.tscn")


# Generates enemies and begins the battle
func initiate_battle():
	print("[BATTLE INIT] initiating battle")
	var battle = BATTLE_CLASS.new(
		generate_enemies(), DEFAULT_BATTLE_BACKGROUND, DEFAULT_BATTLE_MUSIC
	)
	current_battle = battle._duplicate()
	Battled_Enemies = battle.get_enemies()
	get_tree().change_scene("res://code/battle/battle_screen.tscn")


# Finishes a battle and manages EXP, level up and game over
func end_battle(Players, Enemies, Inventory):
	LOCAL.IN_BATTLE = false
	COUNT_IN_BATTLE = {}
	var total_exp = 0

	# Calculates total EXP based on the enemies killed
	for e in Enemies:
		print("[BM] " + e.get_name())
		if e.is_dead():
			print("is dead")
			total_exp += e.get_xp()

	# Level up alive players and resets status/hate
	var level_up = false
	var death = 0
	for p in Players:
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

	GLOBAL.PLAYERS = Players
	GLOBAL.INVENTORY = Inventory

	# Goes to game over, level up scenes or back to the map
	# depending on the outcome of the battle
	if death == len(Players):
		print("[BM] Game over!")
		AUDIO.play_bgm("GAME_OVER_THEME")
		get_tree().change_scene("res://code/battle/post_battle/game_over_screen.tscn")
	elif level_up:
		print("[BM] Someone leveled up")
		get_tree().change_scene("res://code/battle/post_battle/level_up_screen.tscn")
	else:
		print("[BM] Back to the map")
		get_tree().change_scene("res://code/root.tscn")


func _on_Dialogue_Ended():
	get_node("/root/Battle").resume()
	get_node("/root/Battle").emit_signal("event_finished")
