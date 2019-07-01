extends Node2D

onready var Players = []
onready var Inventory = []
onready var Enemies = []
var cara_no_mundo = load("res://Overworld/Cara_no_mundo.tscn")
var Players_pos

func generate_enemies(id):
	var newEnemy = []
	newEnemy.append(Enemies[id].enemy_duplicate())
	randomize()
	var total = int(rand_range(1,4))
	for i in range(total):
		var enemy_id = int(rand_range(1,len(Enemies)))
		newEnemy.append(Enemies[enemy_id].enemy_duplicate())
	return newEnemy

# Called when the node enters the scene tree for the first time.
func _ready():
	Enemies = GLOBAL.ALL_ENEMIES
	if BATTLE_INIT.first:
		Players_pos = [Vector2(500, 300), Vector2(500, 300), Vector2(500, 300), Vector2(500, 300)]
		Players = GLOBAL.ALL_PLAYERS
		Inventory = GLOBAL.INVENTORY
		BATTLE_INIT.init(Players, Enemies)
	else:
		Players_pos = BATTLE_INIT.Position
		Players = BATTLE_INIT.Play
		print("i'mm back, here are players:"+str(Players))
		if Players == []:
			get_tree().change_scene("res://Battle/Game Over.tscn")
	var kill = BATTLE_INIT.kill
	if kill:
		self.get_node(str(kill)).queue_free()
	for i in range(len(Players)):
		var cara = cara_no_mundo.instance()
		cara.set_global_position(Players_pos[i])
		cara.id = i
		$Party.add_child(cara)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_positions()

func update_positions():
	for i in range(len($Party.get_children())):
		Players_pos[i] = $Party.get_child(i).get_global_position()
	BATTLE_INIT.update_global_position(Players_pos)

