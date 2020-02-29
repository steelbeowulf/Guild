extends Node

# Encounter variables
onready var Encounter = []
onready var Kill = []
onready var Enemies = []
onready var Map = null

# Battle variables
onready var Battled_Enemies = []

# Level up variables
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


# Sets the possible pool of enemies to draw from and the map
func init(enemies_arg, map_arg):
	Enemies = enemies_arg
	Map = map_arg

###### ENEMY ENCOUNTER FUNCTIONS #####

# Updates the Encounter and Kill variables based on 
# enemy visibility
func _encounter_management(value, id, name):
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
	if Encounter and Encounter[0] == 9:
		total = 0
		GLOBAL.WIN = true
	
	# Sets enemies on the encounter as dead on the map
	# regardless if player wins (if they lose, it's a game over)
	for k in Kill:
		Map.get_node("Enemies/"+str(k)).dead = true
	
	# Fills the enemy list from the encounter list (monsters the player
	# see on the battlefield) and generates random ones if there's not enough
	var current = 0
	Encounter.shuffle()
	while current <= total:
		if Encounter:
			newEnemy.append(Enemies[Encounter[0]]._duplicate())
			Encounter.pop_front()
		else:
			var enemy_id = 1 + (randi() % (len(Enemies)-2))
			newEnemy.append(Enemies[enemy_id]._duplicate())
		current+=1

	# Returns encounter
	return newEnemy


###### BATTLE MANAGEMENT FUNCTIONS #####

# Generates enemies and begins the battle
func initiate_battle():
	Battled_Enemies = generate_enemies()
	get_tree().change_scene("res://Battle/Battle.tscn")


# Finishes a battle and manages EXP, level up and game over
func end_battle(Players, Enemies, Inventory):
	var total_exp = 0
	
	# Calculates total EXP based on the enemies killed
	for e in Enemies:
		if e.is_dead():
			total_exp += e.get_xp()
	
	# Level up alive players and resets status/hate
	var Play = []
	for p in Players:
		if not p.is_dead():
			# Resets battle stuff
			p.remove_all_status()
			p.zero_hate()
			p.reset_hate()
			
			# Level up logic
			p.xp += total_exp
			var up = ((18/10)^p.level)*5
			if p.xp >= up:
				levelup = 1
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
				
				#HP MAX UP
				randomize()
				var stat_up = int(floor(rand_range(0,5.99)))
				p.set_stats(1, max_hp + stat_up)
				lvup_max_hp = stat_up
				
				#MP MAX UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(3, max_mp + stat_up)
				lvup_max_mp = stat_up
				
				#ATK UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(4, atk + stat_up)
				lvup_atk = stat_up
				
				#ATKM UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(5, atkm + stat_up)
				lvup_atkm = stat_up
				
				#DEF UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(6, def + stat_up)
				lvup_def = stat_up
				
				#DEFM UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(7, defm + stat_up)
				lvup_defm = stat_up
				
				#AGI UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(8, agi + stat_up)
				lvup_agi = stat_up
				
				#ACC UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(9, acc + stat_up)
				lvup_acc = stat_up
				
				#EVA UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(9, eva + stat_up)
				lvup_eva = stat_up
				
				#LCK UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(10, lck + stat_up)
				lvup_lck = stat_up
		Play.append(p)

	GLOBAL.ALL_PLAYERS = Play
	GLOBAL.INVENTORY = Inventory
	
	# Goes to game over, level up scenes or back to the map
	# depending on the outcome of the battle
	if Play == []:
		get_tree().change_scene("res://Battle/Game Over.tscn")
	elif levelup == 1:
		get_tree().change_scene("res://Battle/Level Up.tscn")
	else:
		get_tree().change_scene("res://Root.tscn")