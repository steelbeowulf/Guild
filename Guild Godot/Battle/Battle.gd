extends "Apply.gd"

# Logic Stuff
var Players
var Enemies
var Inventory
var current_entity
var menu_state
var battle_over

var current_action
var current_target

var total_enemies = 0
var total_allies = 0

var boss = false

signal round_finished
signal finish_anim

func _ready():
	GLOBAL.entering_battle = false
	battle_over = false
	Players = GLOBAL.ALL_PLAYERS
	Inventory =  GLOBAL.INVENTORY
	Enemies =  BATTLE_MANAGER.Battled_Enemies
	
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", TEXT.get_font())
	
	for c in get_node("Menu").get_children():
		c.focus_previous = NodePath("Menu/Attack")
	
	for i in range(Players.size()):
		Players[i].index = i
		Players[i].reset_hate()
		for j in range(Enemies.size()):
			Players[i].hate.append(0)

	total_allies = Players.size()
	
	for i in range(Enemies.size()):
		Enemies[i].index = i

	total_enemies = Enemies.size()
	
	$AnimationManager.initialize(Players, Enemies)

	# Change later: demo specific TODO
	if Enemies[0].id == 9:
		boss = true
		AUDIO.play_bgm('BOSS_THEME')
	else:
		AUDIO.play_bgm('BATTLE_THEME')

	# Main battle loop: calls rounds() while the battle isn't battle_over
	while (not battle_over):
		rounds()
		yield(self, "round_finished")
	end_battle()

# A round is comprised of the turns of all entities participating in battle
func rounds():
	# The status "AGILITY" is used to determine the turn order
	var turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")
	
	# Each iteration on this loop is a turn in the game
	for i in range(turnorder.size()):
		current_entity = turnorder[i]
		var next = null
		if i < turnorder.size() - 1:
			next = turnorder[i+1]
		else:
			next = turnorder[0]
		
		var id = current_entity.index

		# If the entity is currently affected by a status, apply its effect
		var can_move = []
		var can_actually_move = 0
		var status = current_entity.get_status()
		LOADER.List = Enemies
		if status:
			var result
			for st in status.keys():
				result = result_status(st, status[st], current_entity, $AnimationManager/Log)
				can_move.append(result[0])
				
			current_entity.decrement_turns()
				
			# Also covers cases in which the action is chosen for you (confuse, paralysis, etc)
			for condition in can_move:
				if condition == -1:
					can_actually_move = -1
				elif condition == -2:
					can_actually_move = -2

		var target = null
		var action = null
		var result = null
		var bounds = []

		if can_actually_move == 0:
			# If the entity is an enemy, leave it to the AI
			if current_entity.classe == "boss":
				var decision = current_entity.AI(Players, Enemies)
				target = decision[1]
				action = decision[0]
				emit_signal("turn_finished")

			# If it's a player, check valid actions (has itens, has MP)
			else:
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
				action = current_action
				target = current_target
				
				# Checks if the battle is over and exits the main loop
				if battle_over:
					break
				
				bounds = recalculate_bounds()

		# Current entity cannot move
		elif can_actually_move == -1:
			action = "Pass"
			target = 0
			emit_signal("turn_finished")
		# Current entity is forced to attack a random enemy
		elif can_actually_move == -2:
			var pref = "E"
			if current_entity.classe == "boss":
				pref = "P"
			randomize()
			target = rand_range(0,LOADER.List.size())
			target = pref+str(floor(target))
			action = "Attack"

		# Actually executes the actions for the turn and animates it
		result = execute_action(action, target)
		target = result[0]
		result = result[1]
		

		$AnimationManager.resolve(current_entity, action, target, result, bounds, next)
		yield($AnimationManager, "animation_finished")
		

		
		get_node("Menu/Attack").grab_focus()
		get_node("Menu/Attack").disabled = false
		get_node("Menu/Attack").set_focus_mode(2)
		
		get_node("Menu/Skills").disabled = false
		get_node("Menu/Skills").set_focus_mode(2)
		
		get_node("Menu/Itens").disabled = false
		get_node("Menu/Itens").set_focus_mode(2)
		
		# Check if all players or enemies are dead
		if check_battle_end():
			

			battle_over = true
			break
	
	# Everyones' turn has finished
	emit_signal("round_finished")

func check_battle_end():
	var dead_allies = 0
	var dead_enemies = 0
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
	

	
	# Attack: the target takes PHYSICAL damage
	if action == "Attack":
		AUDIO.play_se("HIT")
		var dies_on_attack = false
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
			var hate = current_entity.update_hate(dmg, alvo.index)
		if alvo.get_health() <= 0:
			dies_on_attack = true
			alvo.die()
		return [alvo, [dies_on_attack, dmg]]
	
	# Lane: only the player characters may change lanes
	elif action == "Lane":
		AUDIO.play_se("RUN")
		var id = current_entity.index
		var lane = int(target)
		current_entity.set_pos(lane)
		return [0, lane]
	
	# Item: only the player characters may use items
	elif action == "Item":
		AUDIO.play_se("SPELL")
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
		
		var dead = []
		var stat_change = []
		var ailments = []
		var targets = []
		# Apply the effect on all affected
		for alvo in affected:
			# Checks if alvo may be targeted by the item
			if not alvo.is_dead() or item.type == "RESSURECTION":
				item.quantity = item.quantity - 1
				targets.append(alvo)
				if (item.effect != []):
					var result
					for eff in item.effect:
						var times = eff[3]
						for i in range(times):
							result = apply_effect(current_entity, eff, alvo,  alvo.index)
							if result[0] != -1:
								var ret = result[0]
								var type = result[1]
								stat_change.append([ret, type])
				if (item.status != []):
					for st in item.status:
						var ailment = apply_status(st, alvo, current_entity)
						ailments.append(ailment)
				if alvo.get_health() <= 0:
					alvo.die()
					dead.append(alvo)
		
		# No more of the item used
		if item.quantity == 0:
			Inventory.remove(int(target[0]))
		return [targets, [dead, ailments, stat_change]]

	elif action == "Skills":
		AUDIO.play_se("SPELL")
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

		var dead = []
		var ailments = []
		var stats_change = []
		var targets = []
		for alvo in affected:
			dead.append(false)
			if not alvo.is_dead() or skill.type == "RESSURECTION":
				targets.append(alvo)
				var result
				var stat_change = []
				for eff in skill.effect:
					var times = eff[3]
					for i in range(times):
						result = apply_effect(current_entity, eff, alvo,  alvo.index)
						if result[0] != -1:
							var ret = result[0]
							var type = result[1]
							stat_change.append([ret, type])
				if (skill.status != []):
					for st in skill.status:
						var ailment = apply_status(st, alvo, current_entity)
						ailments.append(ailment)
				if alvo.get_health() <= 0:
					alvo.die()
					dead[-1] = true
				stats_change.append(stat_change)
		var mp = current_entity.get_mp()
		
		# Spends the MP
		current_entity.set_stats(MP, mp-skill.quantity)
		return [[targets, skill.quantity], [dead, ailments, stats_change]]
	
	elif action == "Run":
		AUDIO.play_se("RUN")
		randomize()
		var chance = rand_range(0,100)
		return [0, [boss, chance<=75]]
	
	# Literally does nothing
	elif action == "Pass":
		return [0, 0]
	
	
# Auxiliary functions for the action selection
func set_current_action(action):
	current_action = action
	
func set_current_target(target):
	current_target = target


func _process(delta):
	for i in range(len(Players)):
		var p = Players[i]
		if not p.is_dead():
			var index = p.index
			var lane = p.get_pos()
	if Input.is_action_pressed("ui_cancel") and menu_state != null:
		for c in $Menu.get_children():
			c.hide_stuff()
		get_node("Menu/"+str(menu_state)).grab_focus()
		get_node("Menu/"+str(menu_state)).disabled = false
		get_node("Menu/"+str(menu_state)).set_focus_mode(2)


func _on_Lane_button_down():
	menu_state = "Lane"
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
	menu_state = "Itens"
	LOADER.List = Inventory
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Skills").hide()
	get_node("Menu/Run").hide()
	get_node("Menu/Itens").disabled = true
	get_node("Menu/Itens").set_focus_mode(0)
	var itens = get_node("Menu/Itens/Targets/ItemContainer/HBoxContainer/Itens")
	var players = get_node("Menu/Itens/Targets/PlayerContainer/HBoxContainer/Players")
	var enemies = get_node("Menu/Itens/Targets/EnemiesContainer/HBoxContainer/Enemies")
	for i in range(Inventory.size()):
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
		itens.get_node(str(i)).set_text(Inventory[i].nome+" x"+str(Inventory[i].quantity))
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
	menu_state = "Skills"
	LOADER.List = current_entity.get_skills()
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Itens").hide()
	get_node("Menu/Run").hide()
	get_node("Menu/Skills").disabled = true
	get_node("Menu/Skills").set_focus_mode(0)
	var skills = current_entity.get_skills()
	var itens = get_node("Menu/Skills/Targets/ItemContainer/HBoxContainer/Itens")
	var players = get_node("Menu/Skills/Targets/PlayerContainer/HBoxContainer/Players")
	var enemies = get_node("Menu/Skills/Targets/EnemiesContainer/HBoxContainer/Enemies")
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
	menu_state = "Attack"
	var unfocus = true
	get_node("Menu/Skills").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Itens").hide()
	get_node("Menu/Run").hide()
	get_node("Menu/Attack").disabled = true
	get_node("Menu/Attack").set_focus_mode(0)
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
				

				enemies.get_node("E"+str(i)).grab_focus()
				unfocus = false
			enemies.get_node("E"+str(i)).show()
			enemies.get_node("E"+str(i)).disabled = false
			enemies.get_node("E"+str(i)).set_text(Enemies[i].get_name())
	#enemies.get_node("E0").grab_focus()
	get_node("Menu/Attack/").set_pressed(true)
	get_node("Menu/Attack/")._on_Action_pressed()
	get_node("Menu/Attack/").set_pressed(true)

func end_battle():
	$AnimationManager/Log.display_text("Fim de jogo!")
	

	BATTLE_MANAGER.end_battle(Players, Enemies, Inventory)
	#get_tree().change_scene("res://battle_overworld/Map.tscn")

# TODO: there are graphical parts in this, move to ANimationManager
func manage_hate(type, target):
	if type == 0:
		# Focus entered
		for i in range(len(Players)):
			#var img = Players_img[i]
			var p = Players[i]
			#img.display_hate(p.hate[target], target)

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

func _on_Run_button_down():
	menu_state = "Run"
	get_node("Menu/Run/")._on_Action_pressed()