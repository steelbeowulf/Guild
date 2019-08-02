extends Node2D

onready var Players = []
onready var Inventory = []
onready var Enemies = []
onready var Encounter = []
onready var Kill = []
var cara_no_mundo = load("res://Overworld/Cara_no_mundo.tscn")
onready var Player_pos = Vector2(500, 300)

func generate_enemies():
	var newEnemy = []
	var total = int(rand_range(1,4))
	var current = 0
	Encounter.shuffle()
	while current <= total or Encounter:
		if Encounter:
			newEnemy.append(Enemies[Encounter[0]].enemy_duplicate())
			Encounter.pop_front()
		else:
			var enemy_id = int(rand_range(1,len(Enemies)-1))
			newEnemy.append(Enemies[enemy_id].enemy_duplicate())
		current+=1
	BATTLE_INIT.begin_battle(newEnemy, Kill)
	return

# Called when the node enters the scene tree for the first time.
func _ready():
	Enemies = GLOBAL.ALL_ENEMIES
	Encounter = []
	if BATTLE_INIT.first:
		Players = GLOBAL.ALL_PLAYERS
		Inventory = GLOBAL.INVENTORY
		BATTLE_INIT.init(Players, Enemies)
	else:
		Player_pos = GLOBAL.POSITION
		Players = BATTLE_INIT.Play
		print("i'mm back, here are players:"+str(Players))
		if Players == []:
			print("rip")
			get_tree().change_scene("res://Battle/Game Over.tscn")
	var kill = BATTLE_INIT.kill
	if kill:
		for k in kill:
			get_node("Enemies").get_node(str(k)).queue_free()
	var cara = cara_no_mundo.instance()
	var pos = Player_pos
	if GLOBAL.POSITION:
		pos = GLOBAL.POSITION
	cara.set_global_position(pos)
	cara.id = 0
	$Party.add_child(cara)
	
	# Connects itself to monsters
	for e in get_node("Enemies").get_children():
		e.connect("battle_notifier", self, "_encounter_management")

func _encounter_management(value, id, name):
	if value:
		Encounter.append(id)
		Kill.append(name)
	else:
		Encounter.erase(id)
		Kill.erase(name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var pos = $Party.get_child(0).get_global_position()
	GLOBAL.POSITION = pos

