extends Node

# Encounter variables
onready var Encounter = []
onready var Kill = []
onready var Enemies = []
onready var Map = null

# Battle variables
onready var Battled_Enemies = []
onready var background

# Level up variables
onready var leveled_up = [0,0,0,0]
onready var levelup = 0
onready var lvup_max_hp = 0
onready var lvup_max_mp = 0
onready var lvup_agi = 0
onready var lvup_atk = 0 
onready var lvup_atkm = 0 
onready var lvup_def = 0 
onready var lvup_defm = 0 
onready var lvup_acc = 0
onready var lvup_eva = 0  
onready var lvup_lck = 0 

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
	GLOBAL.TRANSITION = -1
	print("[BATTLE INIT] current map: "+str(GLOBAL.get_map()))
	background = load("res://Assets/Backgrounds/forest2.png")

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
	if GLOBAL.entering_battle:
		return
	print("[BM] Encounter Management "+str(value)+", "+name)
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
	var total = 1 + (randi() % 4)
	
	# Checks if it's the demo boss
	# TODO: Make this not hardcoded
	if Encounter:
		if Encounter[0] == 11:
			var max_hp = GLOBAL.ENEMIES[11].get_max_health()
			var num_defeated = GLOBAL.get_event_status("eyeballs_defeated")
			GLOBAL.ENEMIES[11].set_stats(0, max_hp - max_hp*0.1*num_defeated) 
			total = 0
			GLOBAL.WIN = true
		elif Encounter[0] == 9:
			total = 4
		elif Encounter[0] == 10:
			var num_defeated = GLOBAL.get_event_status("eyeballs_defeated")
			GLOBAL.set_event_status("eyeballs_defeated", num_defeated+1)
			total = 0
		
	# Sets enemies on the encounter as dead on the map
	# regardless if player wins (if they lose, it's a game over)
	for k in Kill:
		print("[BM] "+str(k)+" is going to die")
		Map.get_node("Enemies/"+str(k)).dead = true
	
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
			print("OLD: "+GLOBAL.ENEMIES[Encounter[0]].get_name())
			newEnemy.append(GLOBAL.ENEMIES[Encounter[0]]._duplicate())
			print(GLOBAL.ENEMIES[Encounter.pop_front()].get_name())
		else:
			var enemy_id = 1 + (randi() % (len(Enemies)-2))
			print("NEW: "+Enemies[enemy_id].get_name())
			newEnemy.append(Enemies[enemy_id]._duplicate())
		current+=1

	Encounter = []
	# Returns encounter
	return newEnemy


###### BATTLE MANAGEMENT FUNCTIONS #####

# Generates enemies and begins the battle
func initiate_battle():
	print("[BATTLE INIT] initiating battle")
	leveled_up = [0,0,0,0]
	Battled_Enemies = generate_enemies()
	get_tree().change_scene("res://Battle/Battle.tscn")


# Finishes a battle and manages EXP, level up and game over
func end_battle(Players, Enemies, Inventory):
	GLOBAL.IN_BATTLE = false
	var total_exp = 0
	
	# Calculates total EXP based on the enemies killed
	for e in Enemies:
		print("[BM] "+e.get_name())
		if e.is_dead():
			print("is dead")
			total_exp += e.get_xp()
	
	# Level up alive players and resets status/hate
	var Play = []
	for p in Players:
		print("[BM] "+p.get_name())
		if not p.is_dead():
			# Resets battle stuff
			print("is alive")
			p.remove_all_status()
			p.zero_hate()
			p.reset_hate()

			# Level up logic
			p.xp += total_exp
			p.xp = floor(p.xp)
			var up = ceil(pow(1.8, p.level)*5.0)
			while p.xp >= up:
				print("[BM] LEVEL UP: "+str(p.xp)+" > "+str(up))
				levelup = 1
				leveled_up[p.id] = 1
				p.xp = p.xp - up
				p.level += 1
				var max_hp = p.get_max_health()
				var max_mp = p.get_max_mp()
				var agi = p.get_agi()
				var atk = p.get_atk()
				var atkm = p.get_atkm()
				var def = p.get_def()
				var defm = p.get_defm()
				var acc = p.get_acc()
				var eva = p.get_eva()
				var lck = p.get_lck()
				up = ceil(pow(1.8, p.level)*5.0)

				#HP MAX UP
				randomize()
				var stat_up = int(floor(rand_range(0,3.99)))
				p.set_stats(1, max_hp + stat_up)
				lvup_max_hp += stat_up

				#MP MAX UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(3, max_mp + stat_up)
				lvup_max_mp += stat_up

				#ATK UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(4, atk + stat_up)
				lvup_atk += stat_up

				#ATKM UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(5, atkm + stat_up)
				lvup_atkm += stat_up

				#DEF UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(6, def + stat_up)
				lvup_def += stat_up

				#DEFM UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(7, defm + stat_up)
				lvup_defm += stat_up

				#AGI UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(8, agi + stat_up)
				lvup_agi += stat_up

				#ACC UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(9, acc + stat_up)
				lvup_acc += stat_up

				#EVA UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(9, eva + stat_up)
				lvup_eva += stat_up

				#LCK UP
				randomize()
				stat_up = floor(rand_range(0,3.99))
				p.set_stats(10, lck + stat_up)
				lvup_lck += stat_up

		Play.append(p)

	GLOBAL.PLAYERS = Play
	GLOBAL.INVENTORY = Inventory
	
	# Goes to game over, level up scenes or back to the map
	# depending on the outcome of the battle
	var death = 0
	for i in range(len(Play)):
		if Play[i].is_dead():
			 death+=1
	print(len(Play))
	print(death)
	if death == len(Play):
		print("morreu")
		AUDIO.play_bgm("GAME_OVER_THEME")
		get_tree().change_scene("res://Battle/Game Over.tscn")
	elif levelup == 1:
		death = 0
		get_tree().change_scene("res://Battle/Level Up.tscn")
	else:
		death = 0
		get_tree().change_scene("res://Root.tscn")
