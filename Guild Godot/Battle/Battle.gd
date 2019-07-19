extends "Apply.gd"

# Logic Stuff
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

# Graphical stuff
var Players_img = []
var Enemies_img = []

signal round_finished
signal finish_anim

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
	Inventory =  GLOBAL.INVENTORY
	Enemies =  BATTLE_INIT.Enem
	
	for c in get_node("Menu").get_children():
		c.focus_previous = NodePath("Menu/Attack")
	
	var lane
	for i in range(Players.size()):
		# Logic stuff
		Players[i].index = i
		Players[i].reset_hate()
		for j in range(Enemies.size()):
			Players[i].hate.append(0)
		
		# Graphics stuff
		lane = Players[i].get_pos()
		var node = get_node("Players/P"+str(i))
		Players_img.append(node)
		node.parent = self
		node.change_lane(lane)
		node.set_sprite(Players[i].sprite)
		node.show()
		Players[i].graphics = node
		
	total_allies = Players.size()
	for i in range(Enemies.size()):
		Enemies[i].index = i
		lane = Enemies[i].get_pos()
		var node = get_node("Enemies/E"+str(i))
		Enemies_img.append(node)
		node.parent = self
		node.set_sprite(Enemies[i].sprite)
		node.show()
		Enemies[i].graphics = node
	total_enemies = Enemies.size()
	
	# Link target buttons with visual targets
	$Menu/Attack.connect_targets(Players_img, Enemies_img, self)
	$Menu/Skills.connect_targets(Players_img, Enemies_img, self)
	$Menu/Itens.connect_targets(Players_img, Enemies_img, self)
	
	# Main battle loop: calls rounds() while the battle isn't over
	while (not over):
		rounds()
		yield(self, "round_finished")
	$Timer.start()
	yield($Timer, "timeout")
	$Log.display_text("Fim de jogo!")
	print_battle_results()
	BATTLE_INIT.end_battle(Players, Enemies, Inventory)
	get_tree().change_scene("res://Overworld/Map.tscn")

# A round is comprised of the turns of all entities participating in battle
func rounds():
	# The status "AGILITY" is used to determine the turn order
	var turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")
	
	# Each iteration on this loop is a turn in the game
	for i in range(turnorder.size()):
		current_entity = turnorder[i]
		print("turno de: " + str(current_entity.get_name()))
		var id = current_entity.index
		var img
		if current_entity.classe == "boss":
			img = Enemies_img[id]
		else:
			img = Players_img[id]
		
		# If the entity is currently affected by a status, apply its effect
		var can_move = []
		var can_actually_move = 0
		var status = current_entity.get_status()
		LOADER.List = Enemies
		$Timer.wait_time = 1.0
		if status:
			var result
			for st in status.keys():
				result = result_status(st, status[st], current_entity, $Log)
				can_move.append(result[0])
				img.take_damage(result[1], 0)
				
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
				Enemies_img[id].turn()
				print("MOSTRA HATE PLS")
				manage_hate(0, id)
				$Timer.wait_time = 1.5
				$Timer.start()
				yield($Timer, "timeout")
				var decision = current_entity.AI(Players, Enemies)
				print(current_entity.get_name()+" decidiu usar "+decision[0]+" em "+str(decision[1]))
				emit_signal("turn_finished")
				execute_action(decision[0], decision[1])
				Enemies_img[id].end_turn()

			# If it's a player, check valid actions (has itens, has MP)
			else:
				manage_hate(1, id)
				Players_img[id].turn(true)
				if not current_entity.skills or current_entity.get_mp() == 0:
					get_node("Menu/Skills").disabled = true
				else:
					get_node("Menu/Skills").disabled = false
				if Inventory.size() == 0:
					get_node("Menu/Itens").disabled = true
				
				# Show the Menu and wait until action is selected
				get_node("Menu").show()
				for c in get_node("Menu").get_children():
					c.show()
				$Menu/Attack.grab_focus()
				yield($Menu, "turn_finished")
				Players_img[id].end_turn(true)
				execute_action(current_action, current_target)
				var bounds = recalculate_bounds()
				for p in Players_img:
					p.update_bounds(bounds)
		# Current entity cannot move
		elif can_actually_move == -1:
			$Timer.wait_time = 0.1
			execute_action("Pass", 0)
			emit_signal("turn_finished")
		# Current entity is forced to attack a random enemy
		elif can_actually_move == -2:
			var pref = "E"
			if current_entity.classe == "boss":
				pref = "P"
			randomize()
			var target = rand_range(0,LOADER.List.size())
			target = pref+str(floor(target))
			execute_action("Attack", [1, target])
		# Check if all players or enemies are dead
		if check_battle_end():
			print("Hey game over")
			over = true
			break
		
		$Timer.start()
		yield($Timer, "timeout")
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
		var imgs = []
		var alvo = target[1]
		var skitem = int(target[0])
		if alvo.left(1) == "P":
			entities = Players
			imgs = Players_img
		else:
			entities = Enemies
			imgs = Enemies_img
		alvo = int(alvo.right(1))
		alvo = entities[alvo]
		var atk = current_entity.get_atk()
		var dmg = alvo.take_damage(PHYSIC, atk)
		imgs[alvo.index].take_damage(dmg, 0)
		if alvo.classe == "boss" and current_entity.classe != "boss":
			var hate = current_entity.update_hate(dmg, alvo.index)
		$Log.display_text("ATTACK")
		if alvo.get_health() <= 0:
			print("alguém morreu")
			kill(entities, alvo.index)
	
	# Lane: only the player characters may change lanes
	elif action == "Lane":
		var id = current_entity.index
		var lane = int(target)
		current_entity.set_pos(lane)
		$Log.display_text(current_entity.get_name()+" se moveu para a lane "+dlanes[int(target)])
		Players_img[id].change_lane(lane)
	
	# Item: only the player characters may use items
	elif action == "Item":
		# Quick trick to identify if target is friend or foe
		var entities = []
		var imgs = []
		var alvo = target[1]
		var skitem = int(target[0])
		if alvo.left(1) == "P":
			entities = Players
			imgs = Players_img
		else:
			entities = Enemies
			imgs = Enemies_img
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
		
		$Log.display_text(item.nome)
		# Apply the effect on all affected
		for alvo in affected:
			if not alvo.is_dead() or item.type == "RESSURECTION":
				item.quantity = item.quantity - 1
				if (item.effect != []):
					var result
					for eff in item.effect:
						var times = eff[3]
						for i in range(times):
							result = apply_effect(current_entity, eff, alvo,  alvo.index , $Log)
							if result[0] != -1:
								imgs[alvo.index].take_damage(result[0], result[1])
								$Timer.wait_time = 1.0
								$Timer.start()
								yield($Timer, "timeout")
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
		var imgs = []
		var alvo = target[1]
		var skitem = int(target[0])
		if alvo.left(1) == "P":
			entities = Players
			imgs = Players_img
		else:
			entities = Enemies
			imgs = Enemies_img
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
		$Log.display_text(skill.nome)
		for alvo in affected:
			if not alvo.is_dead() or skill.type == "RESSURECTION":
				var result
				for eff in skill.effect:
					var times = eff[3]
					for i in range(times):
						result = apply_effect(current_entity, eff, alvo,  alvo.index , $Log)
						if result[0] != -1:
							imgs[alvo.index].take_damage(result[0], result[1])
							$Timer.wait_time = 1.0
							$Timer.start()
							yield($Timer, "timeout")
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
			get_node("Players/P"+str(index)).show()
	if Input.is_action_pressed("ui_cancel") and state != null:
		for c in $Menu.get_children():
			c.hide_stuff()
		get_node("Menu/"+str(state)).grab_focus()

func _on_Run_button_down():
	#randomize()
	#var run_chance = floor(rand_range(0,99))
	#if (run_chance >=49):
	print("halp")

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
	get_node("Menu/Run").hide()
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
	get_node("Menu/Run").hide()
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
	get_node("Menu/Run").hide()
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
	entity[id].die()

func recalculate_bounds():
	var bounds = []
	for e in Enemies:
		var hatemax = 0
		var id = e.index
		for p in Players:
			if p.hate[id] > hatemax:
				hatemax = p.hate[id]
		bounds.append(hatemax)
	return bounds
	
func manage_hate(type, target):
	if type == 0:
		# Focus entered
		for i in range(len(Players)):
			var img = Players_img[i]
			var p = Players[i]
			img.display_hate(p.hate[target], target)

func _on_Timer_timeout():
	pass

func _finish_anim():
	print("oi")


