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
	Enemies.append(cenaenemy.new([10,10,10,10,9,10], 10, 0, "hold up partner"))
	Enemies.append(cenaenemy.new([10,10,10,10,9,10], 10, 0, "DELET THIS"))
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
			get_node("Menu").hide()
		else:
			print(current.nome, "'s turn!")
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


func _on_Enemy0_pressed():
	get_node("Menu/Attack/Targets").hide()
	print("ouch!")
	Enemies[0].health = Enemies[0].health - 1
	print(Enemies[0].health)
	if Enemies[0].health < 1:
		get_node("E00").hide()
		Enemies.remove(0)


func _on_Enemy1_pressed():
	get_node("Menu/Attack/Targets").hide()
	print("ouch!")
	Enemies[1].health = Enemies[1].health - 1
	print(Enemies[1].health)
	if Enemies[1].health < 1:
		get_node("E10").hide()
		Enemies.remove(1)


func _on_Enemy2_pressed():
	get_node("Menu/Attack/Targets").hide()
	print("ouch!")
	Enemies[2].health = Enemies[2].health - 1
	print(Enemies[2].health)
	if Enemies[2].health < 1:
		get_node("E20").hide()
		Enemies.remove(2)


func _on_Enemy3_pressed():
	get_node("Menu/Attack/Targets").hide()
	print("ouch!")
	Enemies[3].health = Enemies[3].health - 1
	print(Enemies[3].health)
	if Enemies[3].health < 1:
		get_node("E01").hide()
		Enemies.remove(3)


func _on_Enemy4_pressed():
	get_node("Menu/Attack/Targets").hide()
	print("ouch!")
	Enemies[4].health = Enemies[4].health - 1
	print(Enemies[4].health)
	if Enemies[4].health < 1:
		get_node("E02").hide()
		Enemies.remove(4)

func _process(delta):
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/Enemy"+str(i)).hide()
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/Enemy"+str(i)).show()
		get_node("Menu/Attack/Targets/Enemy"+str(i)).set_text(Enemies[i].nome)