extends "Apply.gd"

# Logic Stuff
var Players
var Enemies
var Inventory
var battle_over
var skill

var current_entity
var current_action

var total_enemies = 0
var total_allies = 0

var boss = false
const RUN_CHANCE = 75

signal round_finished
signal finish_anim

func _ready():
	GLOBAL.entering_battle = false
	GLOBAL.IN_BATTLE = true
	battle_over = false
	Players = GLOBAL.PLAYERS
	Inventory =  GLOBAL.INVENTORY
	Enemies =  BATTLE_MANAGER.Battled_Enemies
	$Background.set_texture(BATTLE_MANAGER.background)
	
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", TEXT.get_font())
	
	for c in get_node("Interface/Menu").get_children():
		c.focus_previous = NodePath("Interface/Menu/Attack")
	
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
	if Enemies[0].id == 9 or Enemies[0].id == 11:
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
		print("[BATTLE] Turno de "+current_entity.nome)
		var next = null
		if i < turnorder.size() - 1:
			next = turnorder[i+1]
		else:
			next = turnorder[0]
		var id = current_entity.index

		# TODO: Refactor all this
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
				action = current_entity.AI(Players, Enemies)
				emit_signal("turn_finished")

			# If it's a player, check valid actions (has itens, has MP)
			else:
				if not current_entity.skills or current_entity.get_mp() == 0:
					get_node("Interface/Menu/Skill").disabled = true
				else:
					get_node("Interface/Menu/Skill").disabled = false
				if Inventory.size() == 0:
					get_node("Interface/Menu/Item").disabled = true
				
				# Show the Menu and wait until action is selected
				get_node("Interface/Menu").show()
				for c in get_node("Interface/Menu").get_children():
					c.show()
				$Interface/Menu/Attack.grab_focus()
				yield($Interface, "turn_finished")
				action = current_action
				
				# Checks if the battle is over and exits the main loop
				if battle_over:
					break
				
				bounds = recalculate_bounds()

		# Current entity cannot move
		elif can_actually_move == -1:
			action = Action.new("Pass", 0, [0])
			emit_signal("turn_finished")
		# Current entity is forced to attack a random enemy
		elif can_actually_move == -2:
			randomize()
			if current_entity.classe == "boss":
				target = rand_range(0, Players.size())
			else:
				target = rand_range(0, Enemies.size())
			action = Action.new("Attack", 1, [target])

		# Actually executes the actions for the turn and animates it
		result = execute_action(action)
		if action.get_type() == "Run":
			if not result.is_boss() and result.is_run_successful():
				battle_over = true
				emit_signal("round_finished")
				return
		$AnimationManager.resolve(current_entity, result)
		yield($AnimationManager, "animation_finished")
		
		get_node("Interface/Menu/Attack").grab_focus()
		get_node("Interface/Menu/Attack").disabled = false
		get_node("Interface/Menu/Attack").set_focus_mode(2)
		
		get_node("Interface/Menu/Skill").disabled = false
		get_node("Interface/Menu/Skill").set_focus_mode(2)
		
		get_node("Interface/Menu/Item").disabled = false
		get_node("Interface/Menu/Item").set_focus_mode(2)
		
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
func execute_action(action: Action):
	var action_type = action.get_type()
	print("[BATTLE] Executing action "+str(action.get_type()))
	# Attack: the target takes PHYSICAL damage
	if action_type == "Attack":
		AUDIO.play_se("HIT")
		var death = false
		var entities = []
		var target_id = action.get_targets()[0]
		print("TARGET ID")
		print(target_id)
		if target_id < 0:
			target_id += 1
			entities = Players
		else:
			entities = Enemies
		var target = entities[target_id]
		var atk = current_entity.get_atk()
		var dmg = target.take_damage(PHYSIC, atk)
		if target.classe == "boss" and current_entity.classe != "boss":
			var hate = current_entity.update_hate(dmg, target.index)
		if target.get_health() <= 0:
			death = true
			target.die()
		print("[BATTLE] alvo="+str(target.get_name())+", dies="+str(death)+", dmg="+str(dmg))
		return StatsActionResult.new("Attack", [target], [dmg], [death])
	
	# Lane: only the player characters may change lanes
	elif action_type == "Lane":
		AUDIO.play_se("RUN")
		var lane = action.get_action()
		current_entity.set_pos(lane)
		print("[BATTLE] lane="+str(lane))
		return LaneActionResult.new(lane)
	
	# Item: only the player characters may use items
	elif action_type == "Item":
		AUDIO.play_se("SPELL")
		var targets = action.get_targets()
		var item_id = action.get_action()
		var item = Inventory[item_id]

#		# Itens may target entities, lanes or everyone
#		var affected = []
#		if item.get_target() == "ONE":
#			affected.append(alvo)
#		elif item.get_target() == "LANE":
#			var affected_lane = alvo.get_pos()
#			for p in entities:
#				if p.get_pos() == affected_lane:
#					affected.append(p)
#		elif item.get_target() == "ALL":
#			for p in entities:
#				affected.append(p)
#
		var dead = []
		var stat_change = []
		var ailments = []
		var valid_targets = []
		# Apply the effect on all affected
		for target_id in targets:
			var target
			if target_id < 0:
				target_id += 1
				target = Players[target_id]
			else:
				target = Enemies[target_id]
			# Checks if alvo may be targeted by the item
			var result
			var ret
			var type
			if not target.is_dead() or item.type == "RESSURECTION":
				item.quantity = item.quantity - 1
				valid_targets.append(target)
				stat_change.append([])
				if (item.effect != []):
					for eff in item.effect:
						var times = eff[3]
						for i in range(times):
							result = apply_effect(current_entity, eff, target,  target.index)
							if result[0] != -1:
								ret = result[0]
								type = result[1]
								stat_change[-1].append([ret, type])
				if (item.status != []):
					for st in item.status:
						var ailment = apply_status(st, target, current_entity)
						ailments.append(ailment)
				var dies = target.get_health() <= 0
				dead.append(dies)
				print("[BATTLE] alvo="+str(target.get_name())+", dies="+str(dies)+", ret="+str(ret)+", type="+str(type))
		
		# No more of the item used
		if item.quantity == 0:
			Inventory.remove(item_id)
		
		return StatsActionResult.new("Item", valid_targets, stat_change, dead, item)
		#return [targets, [dead, ailments, stat_change]]

	elif action_type == "Skill":
		AUDIO.play_se("SPELL")
		var targets = action.get_targets()
		var skill_id = action.get_action()
		var skill = current_entity.get_skill(skill_id)

#		# Itens may target entities, lanes or everyone
#		var affected = []
#		if item.get_target() == "ONE":
#			affected.append(alvo)
#		elif item.get_target() == "LANE":
#			var affected_lane = alvo.get_pos()
#			for p in entities:
#				if p.get_pos() == affected_lane:
#					affected.append(p)
#		elif item.get_target() == "ALL":
#			for p in entities:
#				affected.append(p)
#
		var dead = []
		var stat_change = []
		var ailments = []
		var valid_targets = []
		# Apply the effect on all affected
		for target_id in targets:
			var target
			if target_id < 0:
				target_id += 1
				target = Players[target_id]
			else:
				target = Enemies[target_id]
			# Checks if alvo may be targeted by the item
			var result
			var ret
			var type
			if not target.is_dead() or skill.type == "RESSURECTION":
				valid_targets.append(target)
				stat_change.append([])
				if (skill.effect != []):
					for eff in skill.effect:
						var times = eff[3]
						for i in range(times):
							result = apply_effect(current_entity, eff, target,  target.index)
							if result[0] != -1:
								ret = result[0]
								type = result[1]
								stat_change[-1].append([ret, type])
				if (skill.status != []):
					for st in skill.status:
						var ailment = apply_status(st, target, current_entity)
						ailments.append(ailment)
				var dies = target.get_health() <= 0
				dead.append(dies)
				print("[BATTLE] alvo="+str(target.get_name())+", dies="+str(dies)+", ret="+str(ret)+", type="+str(type))
		
		# Spends the MP
		var mp = current_entity.get_mp()
		current_entity.set_stats(MP, mp-skill.quantity)
		return StatsActionResult.new("Skill", valid_targets, stat_change, dead, skill)
	
	elif action_type == "Run":
		AUDIO.play_se("RUN")
		randomize()
		var success = (rand_range(0,100) <= RUN_CHANCE)
		return RunActionResult.new(boss, success)
	
	# Literally does nothing
	elif action_type == "Pass":
		print("[BATTLE] Pass")
		var passAction = ActionResult.new()
		passAction.type = "Pass"
		return passAction
	
	
# Auxiliary functions for the action selection
func set_current_action(action):
	current_action = action

func end_battle():
	print("[BATTLE] Battle End!")
	$AnimationManager/Log.display_text("Fim de jogo!")
	BATTLE_MANAGER.end_battle(Players, Enemies, Inventory)
	#get_tree().change_scene("res://battle_overworld/Map.tscn")


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

# Interface 
func _on_Run_button_down():
	$Interface.prepare_run_action()

func _on_Lane_button_down():
	$Interface.prepare_lane_action(current_entity.get_pos())


func _on_Itens_button_down():
	LOADER.List = Inventory
#	var players = get_node("Interface/Menu/Itens/Targets/PlayerContainer")
#	var enemies = get_node("Interface/Menu/Itens/Targets/EnemiesContainer")
#	for i in range(4):
#		players.get_node("P"+str(i)).hide()
#	for i in range(5):
#		enemies.get_node("E"+str(i)).hide()
#	for i in range(Players.size()):
#		players.get_node("P"+str(i)).show()
#		players.get_node("P"+str(i)).set_text("")
#	for i in range(Enemies.size()):
#		if not Enemies[i].is_dead():
#			enemies.get_node("E"+str(i)).show()
#			enemies.get_node("E"+str(i)).set_text("")
	$Interface.prepare_itens_action(Inventory)

func _on_Skills_button_down():
	var skills = current_entity.get_skills()
	LOADER.List = skills
	$Interface.prepare_skills_action(skills, current_entity.get_mp())
#	var players = get_node("Interface/Menu/Skills/Targets/PlayerContainer/")
#	var enemies = get_node("Interface/Menu/Skills/Targets/EnemiesContainer/")
#	for i in range(4):
#		players.get_node("P"+str(i)).hide()
#	for i in range(5):
#		enemies.get_node("E"+str(i)).hide()
#	for i in range(Players.size()):
#		players.get_node("P"+str(i)).show()
#		players.get_node("P"+str(i)).set_text("")
#	for i in range(Enemies.size()):
#		if not Enemies[i].is_dead():
#			enemies.get_node("E"+str(i)).show()
#			enemies.get_node("E"+str(i)).set_text("")

func _on_Attack_button_down():
	$Interface.prepare_attack_action()
#	var unfocus = true
#	get_node("Interface/Menu/Skill").hide()
#	get_node("Interface/Menu/Lane").hide()
#	get_node("Interface/Menu/Item").hide()
#	get_node("Interface/Menu/Run").hide()
#	get_node("Interface/Menu/Attack").disabled = true
#	get_node("Interface/Menu/Attack").set_focus_mode(0)
#	var players = get_node("Interface/Menu/Attack/Targets/HBoxContainer/Players")
#	var enemies = get_node("Interface/Menu/Attack/Targets/HBoxContainer/Enemies")
#	for i in range(4):
#		players.get_node("P"+str(i)).hide()
#	for i in range(5):
#		enemies.get_node("E"+str(i)).hide()
#	for i in range(Players.size()):
#		players.get_node("P"+str(i)).show()
#		players.get_node("P"+str(i)).disabled = false
#		players.get_node("P"+str(i)).set_text("")
#	for i in range(Enemies.size()):
#		if not Enemies[i].is_dead():
#			if unfocus:
#				enemies.get_node("E"+str(i)).grab_focus()
#				unfocus = false
#			enemies.get_node("E"+str(i)).show()
#			enemies.get_node("E"+str(i)).disabled = false
#			enemies.get_node("E"+str(i)).set_text("")
#	#enemies.get_node("E0").grab_focus()
#	get_node("Interface/Menu/Attack/").set_pressed(true)
#	get_node("Interface/Menu/Attack/")._on_Action_pressed()
#	get_node("Interface/Menu/Attack/").set_pressed(true)

func get_skitem(action_type: String, skitem_id: int) -> Item:
	if action_type == 'Item':
		return Inventory[skitem_id]
	elif action_type == 'Skill':
		return current_entity.get_skill(skitem_id)
	else:
		return null

func _on_Attack_pressed():
	pass # Replace with function body.
