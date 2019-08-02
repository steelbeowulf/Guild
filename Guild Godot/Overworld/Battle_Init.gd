extends Node

onready var first = true
onready var Play
onready var Enem
onready var Inve
onready var Position = []
onready var Leader_pos = [Vector2(500, 320)]
onready var count = 0
onready var kill = []

func init(players, enemies):
	Play = [] + players
	Enem = [] + enemies

func begin_battle(Enemies, OnMap):
	kill.append(OnMap)
	Enem = [] + Enemies
	return

func end_battle(Players, Enemies, Inventory):
	
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
			var up = ((14/10)^p.level)*5
			if p.xp >= up:
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
				#MP MAX UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(3, max_mp + stat_up)
				print(p.get_name()+" ganhou MPMAX +"+ str(stat_up))
				#ATK UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(4, atk + stat_up)
				print(p.get_name()+" ganhou ATK +"+ str(stat_up))
				#ATKM UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(5, atkm + stat_up)
				print(p.get_name()+" ganhou ATKM +"+ str(stat_up))
				#DEF UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(6, def + stat_up)
				print(p.get_name()+" ganhou DEF +"+ str(stat_up))
				#DEFM UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(7, defm + stat_up)
				print(p.get_name()+" ganhou DEFM +"+ str(stat_up))
				#AGI UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(8, agi + stat_up)
				print(p.get_name()+" ganhou AGI +"+ str(stat_up))
				#ACC UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(9, acc + stat_up)
				print(p.get_name()+" ganhou ACC +"+ str(stat_up))
				#LCK UP
				randomize()
				stat_up = floor(rand_range(0,5.99))
				p.set_stats(10, lck + stat_up)
				print(p.get_name()+" ganhou LCK +"+ str(stat_up))
				
			print(p.get_name()+" agora tem "+str(p.xp)+" de experiência no nível "+str(p.level))
			Play.append(p)
		else:
			print("this guy "+p.get_name()+" is dead and will be removed")
	
	Enem = []
	GLOBAL.INVENTORY = [] + Inventory
	GLOBAL.ALL_PLAYERS = Play
	
	print("battle ended, here are play:")
	print(Play)
	
	if Play == []:
		print("whaat")
		get_tree().change_scene("res://Battle/Game Over.tscn")
	else:
		get_tree().change_scene("res://Overworld/Map.tscn")
