extends Node2D
var cenaplayer = preload("res://Player.gd")
var cenaenemy = preload("res://Enemy.gd")
var Players
var Enemies
func InitBattle(Players, Enemies, Normal, Boss, Fboss):
	var lane
	for i in range(Players.size()):
		lane = Players[i].position
		get_node("P"+str(i)+str(lane)).show()
	for i in range(Enemies.size()):
		lane = Enemies[i].position
		get_node("E"+str(i)+str(lane)).show()
		
func _ready():
	Enemies = []
	Players = []
	Enemies.append(cenaenemy.new([10,10,10,10,9,10], 100, 0, "hold up partner"))
	Players.append(cenaplayer.new([10,10,10,10,11,10], 100, 0, "beefy boi"))
	Players.append(cenaplayer.new([10,10,10,10,22,10], 100, 0, "stabby boi"))
	Players.append(cenaplayer.new([10,10,10,10,5,10], 100, 0, "arrow boi"))
	Players.append(cenaplayer.new([10,10,10,10,0,10], 100, 0, "holy boi"))
	InitBattle(Players, Enemies,0,0,0)
	rounds()
	
func rounds():
	var turnorder
	var current
	turnorder = []
	turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")
	for i in range(turnorder.size()):
		current = turnorder[i]
		if current.classe == "boss":
			print("ooga booga")
		else:
			get_node("Menu").show()

func stackagility(a,b):
	return a.stats[4] > b.stats[4]

func _on_Attack_pressed():
	get_node("Menu/Attack/Targets").show()
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/Enemy"+str(i)).show()
		get_node("Menu/Attack/Targets/Enemy"+str(i)).set_text(Enemies[i].nome)


func _on_Lane_pressed():
	pass # Replace with function body.
