extends "res://Classes/Stats.gd"

var cenaplayer = preload("res://Classes/Player.gd")
var cenaenemy = preload("res://Classes/Enemy.gd")
var cenaitem = preload("res://Classes/Itens.gd")

var Players
var Enemies
var Inventory
var over
var current_entity
var current_action
var current_target
var dead_enemies = 0
var dead_allies = 0

signal round_finished

func InitBattle(Players, Enemies, Inventory, Normal, Boss, Fboss):
	var lane
	#var player = LOADER.players_from_file("res://Testes/Players.json")
	#var ite = LOADER.items_from_file("res://Item.json")
	#print(ite)
	var sk = LOADER.items_from_file("res://Testes/Skills.json")
	print(sk)
	for i in range(Players.size()):
		lane = Players[i].get_pos()
		get_node("P"+str(i)+str(lane)).show()
	for i in range(Enemies.size()):
		lane = Enemies[i].get_pos()
		get_node("E"+str(i)+str(lane)).show()

func _ready():
	over = false
	Enemies = []
	Players = []
	Inventory = LOADER.items_from_file("res://Testes/Inventory.json")#[]
	#var skill1 = cenaitem.new("Stab", 10, [[HP, -10, PHYSIC, 1]], [[true, POISON]])
	#var skill2 = cenaitem.new("Double Stab", 15, [[HP, -20, PHYSIC, 1]], [[]])
	var Skills = LOADER.items_from_file("res://Testes/Skills.json")#[skill1, skill2]
	Enemies.append(cenaenemy.new([25,1000,10,10,5,10,9,10], 0, "hold up partner", []))
	Enemies.append(cenaenemy.new([25,1000,10,10,5,10,9,10], 0, "hold up partner2", []))
	Players.append(cenaplayer.new([100,50, 10,10,10,10,11,10], 0, "beefy boi", []))
	Players.append(cenaplayer.new([100,50, 10,10,10,10,22,10], 0, "stabby boi", Skills))
	Players.append(cenaplayer.new([100,50, 10,10,10,10,5,10], 0, "arrow boi", []))
	Players.append(cenaplayer.new([100,50, 10,10,10,10,0,10], 0, "holy boi", []))
	Inventory.append(cenaitem.new("Potion", 3, [[HP, +10, 1]], [[]]))

	InitBattle(Players, Enemies, Inventory, 0,0,0)
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
		if current_entity.classe == "boss":
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
	return Enemies == []

func check_win_battle():
	return dead_allies == Players.size()

func stackagility(a,b):
	return a.get_agi() > b.get_agi()

func execute_action(action, target):
	if action == "Attack":
		var atk = current_entity.get_atk()
		var alvo = Enemies[int(target)]
		print("TARGET IS"+target)
		print(current_entity.get_name()+" EXECUTOU A ACTION "+action+" NO TARGET "+alvo.get_name())
		alvo.take_damage(PHYSIC, atk)
		if alvo.get_health() <= 0:
			Enemies.remove(int(target))
			get_node("E"+target+"0").hide()
	elif action == "Lane":
		for i in range(Players.size()):
			if Players[i].get_name() == current_entity.get_name():
				var lane = current_entity.get_pos()
				current_entity.set_pos(int(target))
				print("P"+str(i)+str(target))
				get_node("P"+str(i)+str(lane)).hide()
				get_node("P"+str(i)+str(target)).show()
	elif action == "Item":
		var entities = []
		target[1] = int(target[1])
		if target[1] > 0:
			entities = Players
			target[1] -= 1
		else:
			entities = Enemies
			target[1] = abs(target[1])-1
		var alvo = entities[target[1]]
		print("TARGET[0]"+target[0])
		print("inventory"+str(Inventory[0].nome))
		var item = Inventory[int(target[0])]
		print(current_entity.get_name()+" USOU O ITEM "+item.nome+" NO TARGET "+alvo.get_name())
		item.quantity = item.quantity - 1
		if (item.effect != []):
			for eff in item.effect:
				apply_effect(eff, alvo)
		if (item.status != []):
			for st in item.status:
				apply_status(st, alvo)
		if item.quantity == 0:
			Inventory.remove(int(target[0]))
		get_node("Menu/Attack").show()
		get_node("Menu/Lane").show()
		get_node("Menu/Skills").show()
		get_node("Menu/Run").show()
		if alvo.get_health() <= 0:
			dead_enemies += 1
			Enemies.remove(int(target[1]))
			get_node("E"+str(target[1])+"0").hide()
	elif action == "Skills":
		var entities = []
		target[1] = int(target[1])
		if target[1] > 0:
			entities = Players
			target[1] -= 1
		else:
			entities = Enemies
			target[1] = abs(target[1])-1
		var alvo = entities[target[1]]
		var skill = current_entity.get_skills()[int(target[0])]
		print(current_entity.get_name()+" USOU O SKILL "+skill.nome+" NO TARGET "+alvo.get_name())
		if (skill.effect != []):
			for eff in skill.effect:
				print(eff)
				apply_effect(eff, alvo)
		if (skill.status != []):
			for st in skill.status:
				apply_status(st, alvo)
		var mp = current_entity.get_mp()
		current_entity.set_stats(MP, mp-skill.quantity)
		get_node("Menu/Attack").show()
		get_node("Menu/Lane").show()
		get_node("Menu/Itens").show()
		get_node("Menu/Run").show()
		if alvo.get_health() <= 0:
			Enemies.remove(int(target[1]))
			get_node("E"+str(target[1])+"0").hide()

func set_current_action(action):
	current_action = action
func set_current_target(target):
	current_target = target

func _process(delta):
	if Inventory.size() == 0:
		get_node("Menu/Itens").disabled = true
	if current_entity.skills.size() == 0:
		get_node("Menu/Skills").disabled = true
	else:
		get_node("Menu/Skills").disabled = false
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/"+str(i)).hide()
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/"+str(i)).show()
		get_node("Menu/Attack/Targets/"+str(i)).set_text(Enemies[i].nome)

func _on_Lane_button_down():
	for i in range(3):
		get_node("Menu/Lane/Targets/"+str(i)).hide()
	get_node("Menu/Lane/Targets").show()
	if current_entity.get_pos() != 0: 
		get_node("Menu/Lane/Targets/0").show()
		get_node("Menu/Lane/Targets/0").set_text("BACK")
	if current_entity.get_pos() != 1: 
		get_node("Menu/Lane/Targets/1").show()
		get_node("Menu/Lane/Targets/1").set_text("MID")
	if current_entity.get_pos() != 2: 
		get_node("Menu/Lane/Targets/2").show()
		get_node("Menu/Lane/Targets/2").set_text("FRONT")


func _on_Itens_button_down():
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Skills").hide()
	get_node("Menu/Run").hide()
	var itens = get_node("Menu/Itens/Targets/HBoxContainer/Itens")
	var players = get_node("Menu/Itens/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Itens/Targets/HBoxContainer/Enemies")
	for i in range(4):
		itens.get_node(str(i)).hide()
	for i in range(1,5):
		players.get_node(str(i)).hide()
	for i in range(-5,0):
		enemies.get_node(str(i)).hide()
	for i in range(Inventory.size()):
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(Inventory[i].nome+" 	x"+str(Inventory[i].quantity))
	for i in range(1, Players.size()+1):
		players.get_node(str(i)).show()
		players.get_node(str(i)).set_text(Players[i-1].get_name()+" "+str(Players[i-1].get_health()))
	for i in range(1, Enemies.size()+1):
		enemies.get_node(str(-i)).show()
		enemies.get_node(str(-i)).set_text(Enemies[abs(i)-1].get_name())


func _on_Skills_button_down():
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Itens").hide()
	get_node("Menu/Run").hide()
	var skills = current_entity.get_skills()
	print(skills)
	var itens = get_node("Menu/Skills/Targets/HBoxContainer/Itens")
	var players = get_node("Menu/Skills/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Skills/Targets/HBoxContainer/Enemies")
	for i in range(4):
		itens.get_node(str(i)).hide()
	for i in range(1,5):
		players.get_node(str(i)).hide()
	for i in range(-5,0):
		enemies.get_node(str(i)).hide()
	for i in range(skills.size()):
		if current_entity.get_mp() < skills[i].quantity:
			itens.get_node(str(i)).disabled = true
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(skills[i].nome)
	for i in range(1, Players.size()+1):
		players.get_node(str(i)).show()
		players.get_node(str(i)).set_text(Players[i-1].get_name()+" "+str(Players[i-1].get_health()))
	for i in range(1, Enemies.size()+1):
		enemies.get_node(str(-i)).show()
		enemies.get_node(str(-i)).set_text(Enemies[abs(i)-1].get_name())

