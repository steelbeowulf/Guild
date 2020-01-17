extends Node

onready var first = true
onready var Play
onready var Enem
onready var Inve
onready var Position = []
onready var Leader_pos = [Vector2(500, 320)]
onready var count = 0
onready var kill = []
onready var levelup = 0
onready var lvup_max_hp = 0
onready var lvup_max_mp = 0
onready var lvup_agi = 0
onready var lvup_atk = 0 
onready var lvup_atkm = 0 
onready var lvup_def = 0 
onready var lvup_defm = 0 
onready var lvup_acc = 0 
onready var lvup_lck = 0 


func init(players, enemies):
	Play = [] + players
	Enem = [] + enemies

func begin_battle(Enemies, OnMap):
	kill = [] + kill + OnMap
	Enem = [] + Enemies
	return

func end_battle(Players, Enemies, Inventory):
	print("ACABOU BATLHAA")
	var total_exp = 0
	for e in Enemies:
		if e.is_dead():
			total_exp += e.get_xp()
	
	Play = []
	for p in Players:
		if not p.is_dead():
			p.remove_all_status()
			p.zero_hate()
			p.reset_hate()
			p.xp += total_exp
			print(p.get_name()+" ganhou "+str(total_exp)+" de experiência!")
			var up = ((18/10)^p.level)*5
			if p.xp >= up:
				levelup = 1
				print(p.get_name()+" aumentou de nível!") 
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
				var lck = p.get_lck()
				#HP MAX UP
				randomize()
				var stat_up = int(floor(rand_range(0,5.99)))
				p.set_stats(1, max_hp + stat_up)
				print(p.get_name()+" ganhou HPMAX +"+ str(stat_up))
				lvup_max_hp = stat_up
				#MP MAX UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(3, max_mp + stat_up)
				print(p.get_name()+" ganhou MPMAX +"+ str(stat_up))
				lvup_max_mp = stat_up
				#ATK UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(4, atk + stat_up)
				print(p.get_name()+" ganhou ATK +"+ str(stat_up))
				lvup_atk = stat_up
				#ATKM UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(5, atkm + stat_up)
				print(p.get_name()+" ganhou ATKM +"+ str(stat_up))
				lvup_atkm = stat_up
				#DEF UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(6, def + stat_up)
				print(p.get_name()+" ganhou DEF +"+ str(stat_up))
				lvup_def = stat_up
				#DEFM UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(7, defm + stat_up)
				print(p.get_name()+" ganhou DEFM +"+ str(stat_up))
				lvup_defm = stat_up
				#AGI UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(8, agi + stat_up)
				print(p.get_name()+" ganhou AGI +"+ str(stat_up))
				lvup_agi = stat_up
				#ACC UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(9, acc + stat_up)
				print(p.get_name()+" ganhou ACC +"+ str(stat_up))
				lvup_acc = stat_up
				#LCK UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(10, lck + stat_up)
				print(p.get_name()+" ganhou LCK +"+ str(stat_up))
				lvup_lck = stat_up
				
			print(p.get_name()+" agora tem "+str(p.xp)+" de experiência no nível "+str(p.level))
			print("My current health is: " + str(p.get_health()))
			Play.append(p)
		else:
			print("this guy "+p.get_name()+" is dead and will be removed")
			Play.append(p)
	for p in Play:
		print("Player atual: " + p.get_name()+ "\n his health: " + str(p.get_health()) )
	
	Enem = []
	GLOBAL.INVENTORY = [] + Inventory
	GLOBAL.ALL_PLAYERS = Play
	
	print("battle ended, here are play:")
	print(Play)
	
	print(levelup)
	if Play == []:
		print("whaat")
		get_tree().change_scene("res://Battle/Game Over.tscn")
	elif (levelup == 1):
		print("Muda pra cena de level up pf")
		get_tree().change_scene("res://Battle/Level Up.tscn")
	else:
		get_tree().change_scene("res://Overworld/Map"+str(GLOBAL.MAP)+".tscn")
