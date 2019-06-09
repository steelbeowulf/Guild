extends "Apply.gd"

var Players
var Enemies
var Inventory
var current_entity
var state
var over
var current_action
var current_target
var dead_allies = 0
var dead_enemies = 0
var total_enemies = 0
var total_allies = 0

signal round_finished

func print_battle_results():
	print("dead_allies="+str(dead_allies))
	print("dead_enemies="+str(dead_enemies))
	for p in Players:
		print(p.get_name()+" tem "+str(p.get_health())+" de vida!")
	for e in Enemies:
		print(e.get_name()+" tem "+str(e.get_health())+" de vida!")

func _ready():
	over = false
	Players = BATTLE_INIT.Play
	Inventory =  BATTLE_INIT.Inve
	Enemies =  BATTLE_INIT.Enem
	
	for c in get_node("Menu").get_children():
		c.focus_previous = NodePath("Menu/Attack")
	
	var lane
	for i in range(Players.size()):
		Players[i].index = i
		lane = Players[i].get_pos()
		get_node("P"+str(i)+str(lane)).show()
		get_node("P"+str(i)+str(0)).texture = load(Players[i].sprite)
		get_node("P"+str(i)+str(1)).texture = load(Players[i].sprite)
		get_node("P"+str(i)+str(2)).texture = load(Players[i].sprite)
		for j in range(Enemies.size()):
			Players[i].hate.append(0)
	total_allies = Players.size()
	for i in range(Enemies.size()):
		Enemies[i].index = i
		lane = Enemies[i].get_pos()
		get_node("E"+str(i)+str(lane)).texture  = load(Enemies[i].sprite)
		get_node("E"+str(i)+str(lane)).show()
	total_enemies = Enemies.size()
	
	# Main battle loop: calls rounds() while the battle isn't over
	while (not over):
		rounds()
		yield(self, "round_finished")
	$Log.display_text("Fim de jogo!")
	print_battle_results()
	BATTLE_INIT.end_battle(Players, Enemies, Inventory)
	get_tree().change_scene("res://Map.tscn")

# A round is comprised of the turns of all entities participating in battle
func rounds():
	# The status "AGILITY" is used to determine the turn order
	var turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")
	
	# Each iteration on this loop is a turn in the game
	for i in range(turnorder.size()):
		current_entity = turnorder[i]
		print("turno de: " + str(current_entity.get_name()))
		
		# If the entity is currently affected by a status, apply its effect
		var can_move = []
		var can_actually_move = 0
		var status = current_entity.get_status()
		LOADER.List = Enemies
		if status:
			for st in status.keys():
				can_move.append(result_status(st, status[st], current_entity, $Log))
			current_entity.decrement_turns()
			print(current_entity.get_name()+" e seu canmove "+str(can_move))
			
			# Also covers cases in which the action is chosen for you (confuse, paralysis, etc)
			for condition in can_move:
				if condition == -1:
					can_actually_move = -1
				elif condition == -2:
					can_actually_move = -2

		if can_actually_move == 0:
			# If the entity is an enemy, leave it to the AI
			if current_entity.classe == "boss":
				var decision = current_entity.AI(Players, Enemies)
				print(current_entity.get_name()+" decidiu usar "+decision[0]+" em "+str(decision[1]))
				emit_signal("turn_finished")
				execute_action(decision[0], decision[1])

			# If it's a player, check valid actions (has itens, has MP)
			else:
				if not current_entity.skills or current_entity.get_mp() == 0:
					get_node("Menu/Skills").disabled = true
				else:
					get_node("Menu/Skills").disabled = false
				if Inventory.size() == 0:
					get_node("Menu/Itens").disabled = true
				
				# Show the Menu and wait until action is selected
				print("1")
				get_node("Menu").show()
				for c in get_node("Menu").get_children():
					c.show()
				print("2")
				$Menu/Attack.grab_focus()
				print("3")
				yield($Menu, "turn_finished")
				print("4")
				execute_action(current_action, current_target)
				print("5")
		# Current entity cannot move
		elif can_actually_move == -1:
			execute_action("Pass", 0)
			emit_signal("turn_finished")
		# Current entity is forced to attack a random enemy
		elif can_actually_move == -2:
			randomize()
			var rand = rand_range(-LOADER.List.size(), 0)
			execute_action("Attack", rand)
		# Check if all players or enemies are dead
		if check_battle_end():
			print("Hey game over")
			over = true
			break
	emit_signal("round_finished")

func check_battle_end():
	dead_allies = 0
	dead_enemies = 0
	for p in Players:
		if p.is_dead():
			dead_allies += 1
	for e in Enemies:
		if e.is_dead():
			dead_enemies += 1
	return dead_allies == total_allies or dead_enemies == total_enemies

# Auxiliary function to sort the turnorder vector
func stackagility(a,b):
	return a.get_agi() > b.get_agi()

# Executes an action on a given target
func execute_action(action, target):
	print("ex_action "+action+", "+str(target))
	
	# Attack: the target takes PHYSICAL damage
	if action == "Attack":
		var entities = []
		var alvo = target[1]
		var skitem = int(target[0])
		if alvo.left(1) == "P":
			entities = Players
		else:
			entities = Enemies
		alvo = int(alvo.right(1))
		alvo = entities[alvo]
		var atk = current_entity.get_atk()
		var dmg = alvo.take_damage(PHYSIC, atk)
		if alvo.classe == "boss" and current_entity.classe != "boss":
			current_entity.update_hate(dmg, alvo.index)
		$Log.display_text(current_entity.get_name()+" atacou "+alvo.get_name()+", causando "+str(dmg)+" de dano "+dtype[PHYSIC])
		if alvo.get_health() <= 0:
			kill(entities, alvo.index)
	
	# Lane: only the player characters may change lanes
	elif action == "Lane":
		for i in range(Players.size()):
			if Players[i] == current_entity:
				var lane = current_entity.get_pos()
				current_entity.set_pos(int(target))
				$Log.display_text(current_entity.get_name()+" se moveu para a lane "+dlanes[int(target)])
				get_node("P"+str(i)+str(lane)).hide()
				get_node("P"+str(i)+str(target)).show()
	
	# Item: only the player characters may use items
	elif action == "Item":
		# Quick trick to identify if target is friend or foe
		var entities = []
		var alvo = target[1]
		var skitem = int(target[0])
		if alvo.left(1) == "P":
			entities = Players
		else:
			entities = Enemies
		alvo = int(alvo.right(1))
		alvo = entities[alvo]
		var item = Inventory[skitem]
		
		# Itens may target entities, lanes or everyone
		var affected = []
		if item.get_target() == "ONE":
			affected.append(alvo)
		elif item.get_target() == "LANE":
			var affected_lane = alvo.get_pos()
			for p in entities:
				if p.get_pos() == affected_lane:
					affected.append(p)
		elif item.get_target() == "ALL":
			for p in entities:
				affected.append(p)
		
		# Apply the effect on all affected
		for alvo in affected:
			if not alvo.is_dead() or item.type == "RESSURECTION":
				$Log.display_text(current_entity.get_name()+" usou o item "+item.nome+" em "+alvo.get_name())
				item.quantity = item.quantity - 1
				if (item.effect != []):
					for eff in item.effect:
						apply_effect(current_entity, eff, alvo,  alvo.index , $Log)
				if (item.status != []):
					for st in item.status:
						apply_status(st, alvo, current_entity, $Log)
				if alvo.get_health() <= 0:
					kill(entities, alvo.index)
		
		# No more of the item used
		if item.quantity == 0:
			Inventory.remove(int(target[0]))
		
		get_node("Menu/Attack").show()
		get_node("Menu/Lane").show()
		get_node("Menu/Skills").show()
#		get_node("Menu/Run").show()

	elif action == "Skills":
		var entities = []
		var alvo = target[1]
		var skitem = int(target[0])
		if alvo.left(1) == "P":
			entities = Players
		else:
			entities = Enemies
		alvo = int(alvo.right(1))
		alvo = entities[alvo]
		var skill = current_entity.get_skills()[skitem]
		
		var affected = []
		if skill.get_target() == "ONE":
			affected.append(alvo)
		elif skill.get_target() == "LANE":
			var affected_lane = alvo.get_pos()
			for p in entities:
				if p.get_pos() == affected_lane:
					affected.append(p)
		elif skill.get_target() == "ALL":
			for p in entities:
				affected.append(p)
		for alvo in affected:
			if not alvo.is_dead() or skill.type == "RESSURECTION":
				$Log.display_text(current_entity.get_name()+" usou a habilidade "+skill.nome+" em "+alvo.get_name())
				if (skill.effect != []):
					for eff in skill.effect:
						apply_effect(current_entity, eff, alvo, int(target[1]), $Log)
				if (skill.status != []):
					for st in skill.status:
						apply_status(st, alvo, current_entity, $Log)
				if alvo.get_health() <= 0:
					kill(entities, alvo.index)
		var mp = current_entity.get_mp()
		
		# Spends the MP
		current_entity.set_stats(MP, mp-skill.quantity)
		get_node("Menu/Attack").show()
		get_node("Menu/Lane").show()
		get_node("Menu/Itens").show()
#		get_node("Menu/Run").show()
	# Literally does nothing
	elif action == "Pass":
		pass

# Auxiliary functions for the action selection
func set_current_action(action):
	current_action = action
	
func set_current_target(target):
	current_target = target

func _process(delta):
	for p in Players:
		if not p.is_dead():
			var index = p.index
			var lane = p.get_pos()
			get_node("P"+str(index)+str(lane)).show()
	if Input.is_action_pressed("ui_cancel") and state != null:
		for c in $Menu.get_children():
			c.hide_stuff()
		get_node("Menu/"+str(state)).grab_focus()

func _on_Lane_button_down():
	state = "Lane"
	for i in range(3):
		get_node("Menu/Lane/Targets/"+str(i)).hide()
	get_node("Menu/Lane/Targets").show()
	if current_entity.get_pos() != 2: 
		get_node("Menu/Lane/Targets/2").show()
		get_node("Menu/Lane/Targets/2").grab_focus()
		get_node("Menu/Lane/Targets/2").set_text("FRONT")
	if current_entity.get_pos() != 1: 
		get_node("Menu/Lane/Targets/1").show()
		get_node("Menu/Lane/Targets/1").grab_focus()
		get_node("Menu/Lane/Targets/1").set_text("MID")
	if current_entity.get_pos() != 0: 
		get_node("Menu/Lane/Targets/0").show()
		get_node("Menu/Lane/Targets/0").grab_focus()
		get_node("Menu/Lane/Targets/0").set_text("BACK")
	get_node("Menu/Lane/")._on_Action_pressed()

func _on_Itens_button_down():
	state = "Itens"
	LOADER.List = Inventory
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Skills").hide()
#	get_node("Menu/Run").hide()
	var itens = get_node("Menu/Itens/Targets/HBoxContainer/Itens")
	var players = get_node("Menu/Itens/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Itens/Targets/HBoxContainer/Enemies")
	for i in range(5):
		itens.get_node(str(i)).hide()
	for i in range(4):
		players.get_node("P"+str(i)).hide()
	for i in range(5):
		enemies.get_node("E"+str(i)).hide()
	for i in range(Inventory.size()):
		if Inventory[i].quantity == 0:
			itens.get_node(str(i)).disabled = true
		else:
			itens.get_node(str(i)).disabled = false
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(Inventory[i].nome)
	for i in range(Players.size()):
		players.get_node("P"+str(i)).show()
		players.get_node("P"+str(i)).set_text(Players[i].get_name()+"   HP:"+str(Players[i].get_health())+"/"+str(Players[i].get_max_health())+"        MP: "+str(Players[i].get_mp())+"/"+str(Players[i].get_max_mp()))
	for i in range(Enemies.size()):
		if not Enemies[i].is_dead():
			enemies.get_node("E"+str(i)).show()
			enemies.get_node("E"+str(i)).set_text(Enemies[i].get_name())
	itens.get_node("0").grab_focus()
	LOADER.List = Inventory
	get_node("Menu/Itens/")._on_Action_pressed()

func _on_Skills_button_down():
	state = "Skills"
	LOADER.List = current_entity.get_skills()
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Itens").hide()
#	get_node("Menu/Run").hide()
	var skills = current_entity.get_skills()
	var itens = get_node("Menu/Skills/Targets/HBoxContainer/Itens")
	var players = get_node("Menu/Skills/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Skills/Targets/HBoxContainer/Enemies")
	for i in range(5):
		itens.get_node(str(i)).hide()
	for i in range(4):
		players.get_node("P"+str(i)).hide()
	for i in range(5):
		enemies.get_node("E"+str(i)).hide()
	for i in range(skills.size()):
		if current_entity.get_mp() < skills[i].quantity:
			itens.get_node(str(i)).disabled = true
		else:
			itens.get_node(str(i)).disabled = false
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(skills[i].nome)
	for i in range(Players.size()):
		players.get_node("P"+str(i)).show()
		players.get_node("P"+str(i)).set_text(Players[i].get_name()+"   HP:"+str(Players[i].get_health())+"/"+str(Players[i].get_max_health())+"        MP: "+str(Players[i].get_mp())+"/"+str(Players[i].get_max_mp()))
	for i in range(Enemies.size()):
		if not Enemies[i].is_dead():
			enemies.get_node("E"+str(i)).show()
			enemies.get_node("E"+str(i)).set_text(Enemies[i].get_name())
	itens.get_node("0").grab_focus()
	LOADER.List = current_entity.get_skills()
	get_node("Menu/Skills/")._on_Action_pressed()

func _on_Attack_button_down():
	state = "Attack"
	var unfocus = true
	get_node("Menu/Skills").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Itens").hide()
#	get_node("Menu/Run").hide()
	var players = get_node("Menu/Attack/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Attack/Targets/HBoxContainer/Enemies")
	for i in range(4):
		players.get_node("P"+str(i)).hide()
	for i in range(5):
		enemies.get_node("E"+str(i)).hide()
	for i in range(Players.size()):
		players.get_node("P"+str(i)).show()
		players.get_node("P"+str(i)).disabled = false
		players.get_node("P"+str(i)).set_text(Players[i].get_name()+"   HP:"+str(Players[i].get_health())+"/"+str(Players[i].get_max_health())+"        MP: "+str(Players[i].get_mp())+"/"+str(Players[i].get_max_mp()))
	for i in range(Enemies.size()):
		if not Enemies[i].is_dead():
			if unfocus:
				print("unfocus on me E"+str(i)+" which is "+Enemies[i].get_name())
				enemies.get_node("E"+str(i)).grab_focus()
				unfocus = false
			enemies.get_node("E"+str(i)).show()
			enemies.get_node("E"+str(i)).disabled = false
			enemies.get_node("E"+str(i)).set_text(Enemies[i].get_name())
	#enemies.get_node("E0").grab_focus()
	get_node("Menu/Attack/").set_pressed(true)
	get_node("Menu/Attack/")._on_Action_pressed()
	get_node("Menu/Attack/").set_pressed(true)

func kill(entity, id):
	print(entity[id].get_name()+" morreu")
	entity[id].set_stats(HP, 0)
	var a
	var b
	if entity[id].classe == "boss":
		a = "E"
		b = "0"
	else:
		a = "P"
		entity[id].zero_hate()
		b = str(entity[id].get_pos())
	entity[id].add_status("KO", 999, 0)
	get_node(a+str(id)+b).hide()
	#entity.remove(id)
