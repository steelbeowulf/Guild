extends Node

onready var first = true
onready var Play
onready var Enem
onready var Inve
onready var Position = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
onready var Backs = [Vector2(0,0), Vector2(0,0), Vector2(0,0)]
onready var Vel = [Vector2(0,0), Vector2(0,0), Vector2(0,0)]

func init(Players, Enemies, Inventory):
	Play =  [] + Players
	Enem = [] + Enemies
	Inve = [] + Inventory
	first = false
	return

func get_back_pos(id):
	return [Backs[id-1], Vel[id-1]]


func update_global_position(Players_pos, Backs_pos, Velocities):
	print("updating pos")
	Position = [] + Players_pos
	Backs = [] + Backs_pos
	Vel = [] + Velocities

func begin_battle(Enemies):
	Enem = [] + Enemies
	return

func end_battle(Players, Enemies, Inventory):
	var total_exp = 0
	for e in Enemies:
		total_exp += e.get_xp()
	
	for p in Players:
		p.xp += total_exp
		print(p.get_name()+" ganhou "+str(total_exp)+" de experiência!")
		var up = STATS.level_max_exp[p.level]
		if p.xp >= up:
			print(p.get_name()+" aumentou de nível!") 
			p.xp = p.xp - up
			p.level += 1
		print(p.get_name()+" agora tem "+str(p.xp)+" de experiência no nível "+str(p.level))
	
	Play =  [] + Players
	Enem = []
	Inve = [] + Inventory
	return
