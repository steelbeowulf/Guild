extends "res://stats.gd"

var cenaplayer = preload("res://Player.gd")
var cenaenemy = preload("res://Enemy.gd")
var Players
var Enemies
var over
var current_entity
var current_action
var current_target
var dead_enemies = 0
var dead_allies = 0

signal round_finished

func InitBattle(Players, Enemies, Normal, Boss, Fboss):
	var lane
	var player = LOADER.players_from_file("res://Test.json")
	for i in range(Players.size()):
		lane = Players[i].position
		get_node("P"+str(i)+str(lane)).show()
	for i in range(Enemies.size()):
		lane = Enemies[i].position
		get_node("E"+str(i)+str(lane)).show()

func _ready():
	over = false
	Enemies = []
	Players = []
	Enemies.append(cenaenemy.new([10,10,5,10,9,10], 25, 0, "hold up partner"))
	Players.append(cenaplayer.new([10,10,10,10,11,10], 100, 0, "beefy boi"))
	Players.append(cenaplayer.new([10,10,10,10,22,10], 100, 0, "stabby boi"))
	Players.append(cenaplayer.new([10,10,10,10,5,10], 100, 0, "arrow boi"))
	Players.append(cenaplayer.new([10,10,10,10,0,10], 100, 0, "holy boi"))
	InitBattle(Players, Enemies,0,0,0)
	while (not over):
		rounds()
		yield(self, "round_finished")
	print("FIM DE JOGO")

func rounds():
	var turnorder
	turnorder = []
	turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")
	for i in range(turnorder.size()):
		current_entity = turnorder[i]
		if current_entity.get_health() == 0:
			continue
		elif current_entity.classe == "boss":
			print("ooga booga")
			#current.AI()
		else:
			get_node("Menu").show()
			yield($Menu, "turn_finished")
			execute_action(current_action, current_target)
			if check_game_over() or check_win_battle():
				over = true
				break
	emit_signal("round_finished")

func check_game_over():
	return dead_enemies == Enemies.size()

func check_win_battle():
	return dead_allies == Players.size()

func stackagility(a,b):
	return a.get_agi() > b.get_agi()

func execute_action(action, target):
	if action == "Attack":
		var atk = current_entity.get_atk()
		var alvo = Enemies[int(target)]
		print(current_entity.get_name()+" EXECUTOU A ACTION "+action+" NO TARGET "+alvo.get_name())
		alvo.take_damage(PHYSIC, atk)
		if alvo.get_health() <= 0:
			dead_enemies += 1
			get_node("E"+target+"0").hide()

func set_current_action(action):
	current_action = action
	
func set_current_target(target):
	current_target = target

func _on_Attack_pressed():
	get_node("Menu/Attack/Targets").show()
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/Enemy"+str(i)).show()
		get_node("Menu/Attack/Targets/Enemy"+str(i)).set_text(Enemies[i].nome)


func _on_Lane_pressed():
	pass # Replace with function body.
