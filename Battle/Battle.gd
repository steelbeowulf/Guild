extends "Apply.gd"

# Logic Stuff
var Players
var Enemies
var Inventory
var battle_over
var skill

var current_entity
var current_action
var turnorder = []

var total_enemies = 0
var total_allies = 0

var boss = false
const RUN_CHANCE = 75


var forced_agent = null
var next = null

signal round_finished
signal finish_anim
signal event_finished

func show_enabled_actions():
	var menu_children = get_node("Interface/Menu").get_children()
	menu_children.invert()
	for action in menu_children:
		action.hide()
		var key = "can_battle_" + action.get_name().to_lower()
		if EVENTS.get_flag(key):
			action.allowed = true
			action.disabled = false
			action.set_focus_mode(2)
			action.grab_focus()
			action.show()

func block_player_input():
	var menu_children = get_node("Interface/Menu").get_children()
	for c in menu_children:
		c.disabled = true

func update_turnorder():
	turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")

func add_players(players):
	players.sort_custom(self, "stackagility")
	for p in players:
		Players.append(p)
		$AnimationManager.add_player(p)
		for e in Enemies:
			p.hate.append(0)
		p.index = total_allies
		total_allies += 1
		turnorder.append(p)
	print("[BATTLE REINFORCEMENTS] awaiting animations")
	yield($AnimationManager, "animation_finished")
	print("[BATTLE REINFORCEMENTS] animations finished")
	$AnimationManager.entering = false
	if(len(EVENTS.events) > 0 or !call_deferred("trigger_event", "on_reinforcements")):
		EVENTS.event_ended()


func add_enemies(enemies):
	enemies.sort_custom(self, "stackagility")
	battle_over = false
	for e in enemies:
		e.nome = BATTLE_MANAGER.get_next_name_in_battle(e.id)
		Enemies.append(e)
		$AnimationManager.add_enemy(e)
		e.index = total_enemies
		total_enemies += 1
		for p in Players:
			p.hate.append(0)
		turnorder.append(e)
	print("[BATTLE REINFORCEMENTS] awaiting animations")
	yield($AnimationManager, "animation_finished")
	print("[BATTLE REINFORCEMENTS] animations finished")
	$AnimationManager.entering = false
	if(len(EVENTS.events) > 0 or !call_deferred("trigger_event", "on_reinforcements")):
		EVENTS.event_ended()


func _ready():
	LOCAL.entering_battle = false
	LOCAL.IN_BATTLE = true
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
	
	AUDIO.play_bgm(BATTLE_MANAGER.music)

	# Hide actions that are still locked
	show_enabled_actions()
	block_player_input()

	print("[BATTLE] waiting for entrance animations")
	yield($AnimationManager, "animation_finished")
	$AnimationManager.entering = false
	print("[BATTLE] entrance animations finished")

	# Main battle loop: calls rounds() while the battle isn't battle_over
	call_deferred("trigger_event", "on_begin")
	yield(self, "event_finished")
	if forced_agent != null:
		next = forced_agent
		forced_agent = null
	while (not battle_over):
		rounds()
		yield(self, "round_finished")
	call_deferred("trigger_event", "on_end")
	yield(self, "event_finished")
	end_battle()


func trigger_event(condition: String):
	if BATTLE_MANAGER.current_battle.get_events(condition):
		EVENTS.play_events(BATTLE_MANAGER.current_battle.get_events(condition))
		return true
	return false


func force_next_action(agent: Entity):
	forced_agent = agent


func check_for_events(result: ActionResult):
	print("[BATTLE EVENT CHECK] "+result.format())
	var should_play = []
	if result.get_type() == "Pass" or result.get_type() == "Lane":
		return false
	if result.get_type() == "Item" and BATTLE_MANAGER.current_battle.get_events("on_item_use"):
		var events = BATTLE_MANAGER.current_battle.get_events("on_item_use")
		for event in events:
			if result.get_spell().get_name() == event.get_argument(0):
				should_play.append(event)
	if result.get_type() == "Skill" and BATTLE_MANAGER.current_battle.get_events("on_skill_use"):
		var events = BATTLE_MANAGER.current_battle.get_events("on_skill_use")
		for event in events:
			if result.get_spell().get_name() == event.get_argument(0):
				should_play.append(event)
	
	var deaths = result.get_deaths()
	var actor = result.get_actor()
	if BATTLE_MANAGER.current_battle.get_events("on_target_death") and deaths.has(true):
		var events = BATTLE_MANAGER.current_battle.get_events("on_target_death")
		for event in events:
			for i in range(len(deaths)):
				if deaths[i]:
					var target: Entity = result.get_targets()[i]
					if target.get_name() == event.get_argument(0):
						if event.get_argument(1) == null or event.get_argument(1) == actor.get_name():
							should_play.append(event)
	if BATTLE_MANAGER.current_battle.get_events("on_target_damage") or BATTLE_MANAGER.current_battle.get_event("on_target_critical_health"):
		var events = BATTLE_MANAGER.current_battle.get_events("on_target_damage")
		for event in events:
			for target in result.get_targets():
				if BATTLE_MANAGER.current_battle.get_events("on_target_critical_health"):
					var critical_events = BATTLE_MANAGER.current_battle.get_events("on_target_critical_health")
					for critical_event in critical_events:
						if target.get_name() == critical_event.get_argument(0) and target.is_critical_health():
							if event.get_argument(1) == null or event.get_argument(1) == actor.get_name():
								should_play.append(critical_event)
				if event and target.get_name() == event.get_argument(0):
					if event.get_argument(1) == null or event.get_argument(1) == actor.get_name():
						should_play.append(event)
	if len(should_play) == 0:
		return false
	print("[BATTLE EVENTS] Will try to play: ", format_events(should_play))
	return EVENTS.play_events(should_play)

func format_events(events):
	var formatted = ""
	for e in events:
		formatted += e.get_type() + str(e.get_arguments()) + "\n"
	return formatted 


func pause():
	get_tree().paused = true

func resume():
	get_tree().paused = false

# A round is comprised of the turns of all entities participating in battle
func rounds():
	# The status "AGILITY" is used to determine the turn order
	update_turnorder()
	
	# Each iteration on this loop is a turn in the game
	for i in range(turnorder.size()):
		for e in Enemies:
			e.update_target(Players, Enemies)
		
		current_entity = turnorder[i]
		
		if next != null:
			current_entity = next
			next = null
		
		print("[BATTLE] Turno de "+current_entity.nome)
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
			print("[BATTLE] " + current_entity.get_name() + " status: "+ str(status))
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

		print("[BATTLE] " + current_entity.get_name() + " can move? "+ str(can_actually_move))
		if can_actually_move == 0:
			current_entity.graphics.set_turn(true)
			# If the entity is an enemy, leave it to the AI
			if current_entity.classe == "boss":
				block_player_input()
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
				show_enabled_actions()
				yield($Interface, "turn_finished")
				action = current_action
				
				# Checks if the battle is over and exits the main loop
				if battle_over:
					break
				
				bounds = recalculate_bounds()

		# Current entity cannot move
		elif can_actually_move == -1:
			action = Action.new("Pass", 0, [0])
			#emit_signal("turn_finished")
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
		print("[BATTLE] Waiting for animations...")
		yield($AnimationManager, "animation_finished")
		print("[BATTLE] Animations have finished!")
		if call_deferred("check_for_events", result):
			print("[BATTLE] Waiting for events...")
			yield(self, "event_finished")
			if forced_agent != null:
				next = forced_agent
				forced_agent = null
			print("[BATTLE] Events have finished!")
		
		# Hide actions that are still locked
		for action in $Interface/Menu.get_children():
			action.hide()
		show_enabled_actions()
		
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
	var death_events = BATTLE_MANAGER.current_battle.get_events("on_target_death")
	var can_end = true
	for e in death_events:
		if e.get_type() == "REINFORCEMENTS" and !e.has_played():
			can_end = false
	return (dead_allies == total_allies) or (can_end and dead_enemies == total_enemies)

# Auxiliary function to sort the turnorder vector
func stackagility(a,b):
	return a.get_agi() > b.get_agi()

# Executes an action on a given target
func execute_action(action: Action):
	var action_type = action.get_type()
	print("[BATTLE] Executing action "+str(action.get_type()))
	# Attack: the target takes PHYSICAL damage
	if action_type == "Attack":
		var death = false
		var entities = []
		var target_id = action.get_targets()[0]
		
		# Get target from entity list
		print("[BATTLE] Target_id: ", target_id)
		if target_id < 0:
			target_id += 1
			entities = Players
		else:
			entities = Enemies
		var target = entities[abs(target_id)]
		
		# Create BaseStatEffect
		var STATS_CLASS = load("res://Classes/Events/StatEffect.gd")
		var attackEffect = STATS_CLASS.new(HP, "HP", -current_entity.get_atk(), "PHYSIC")
		var hit = true
		var dmg = 0
		var result = 0
		var hate = 0
		var accuracy = current_entity.get_acc()
		var evasion = target.get_eva()
		if(evasion < accuracy):
			hit = true
		elif(floor(rand_range(0, 101)) > 80):
			hit = true
		else:
			false
		if(hit):
			AUDIO.play_se("HIT")
			result = apply_effect(current_entity, attackEffect, target, action_type, hit)
			dmg = 0
			#var dmg = target.take_damage(PHYSIC, atk)
			if target.classe == "boss" and current_entity.classe != "boss":
				hate = current_entity.update_hate(dmg, target.index)
		else:
			#Doesn't exist yet
			AUDIO.play_se("MISS")
			result = apply_effect(current_entity, attackEffect, target, action_type, hit)
			dmg = 0
			return StatsActionResult.new("Miss", [target], [dmg], [death])
		if target.get_health() <= 0:
			death = true
			target.die()
		print("[BATTLE] alvo="+str(target.get_name())+", dies="+str(death)+", dmg="+str(dmg))
		return StatsActionResult.new("Attack", current_entity, [target], [dmg], [death])
	
	# Lane: only the player characters may change lanes
	elif action_type == "Lane":
		AUDIO.play_se("RUN")
		var lane = action.get_action()
		current_entity.set_pos(lane)
		print("[BATTLE] lane="+str(lane))
		return LaneActionResult.new(lane)
	
	# Item: only the player characters may use items
	elif action_type == "Item":
		AUDIO.play_se("SPELL", -12)
		var targets = action.get_targets()
		var item_id = action.get_action()
		var item = Inventory[item_id]

		var dead = []
		var stat_change = []
		var ailments = []
		var valid_targets = []
		# Apply the effect on all affected
		for target_id in targets:
			# Get correct target
			var target
			if target_id < 0:
				target_id += 1
				target = Players[abs(target_id)]
			else:
				target = Enemies[target_id]
			
			# Checks if target may be targeted by the item
			var result
			var ret
			var type
			if not target.is_dead() or item.type == "RESSURECTION":
				item.quantity = item.quantity - 1
				valid_targets.append(target)
				stat_change.append([])

				for eff in item.effect:
					# TODO: Add times attribute back to StatEffect
					var times = 1#eff[3]
					for i in range(times):
						result = apply_effect(current_entity, eff, target, action_type, true)
						if result[0] != -1:
							ret = result[0]
							type = result[1]
							stat_change[-1].append([ret, type])

				for st in item.status:
					var ailment = apply_status(st, target, current_entity)
					ailments.append(ailment)
				var dies = target.get_health() <= 0
				if dies:
					target.die()
				dead.append(dies)
				print("[BATTLE] alvo="+str(target.get_name())+", dies="+str(dies)+", ret="+str(ret)+", type="+str(type))
		
		# No more of the item used
		if item.quantity == 0:
			Inventory.remove(item_id)
		
		return StatsActionResult.new("Item", current_entity, valid_targets, stat_change, dead, item)

	elif action_type == "Skill":
		AUDIO.play_se("SPELL", -12)
		var targets = action.get_targets()
		var skill_id = action.get_action()
		var skill = current_entity.get_skill(skill_id)

		var dead = []
		var stat_change = []
		var ailments = []
		var valid_targets = []
		var hit = true
		# Apply the effect on all affected
		for target_id in targets:
			var target
			if target_id < 0:
				target_id += 1
				target = Players[abs(target_id)]
			else:
				target = Enemies[abs(target_id)]
			# Checks if alvo may be targeted by the item
			var result
			var ret
			var type
			if not target.is_dead() or skill.type == "RESSURECTION":
				valid_targets.append(target)
				stat_change.append([])

				for eff in skill.effect:
					var times = 1#eff[3]
					for i in range(times):
						result = apply_effect(current_entity, eff, target, action_type, hit)
						if result[0] != -1:
							ret = result[0]
							type = result[1]
							stat_change[-1].append([ret, type])

				for st in skill.status:
					var ailment = apply_status(st, target, current_entity)
					ailments.append(ailment)
				var dies = target.get_health() <= 0
				if dies:
					target.die()
				dead.append(dies)
				print("[BATTLE] alvo="+str(target.get_name())+", dies="+str(dies)+", ret="+str(ret)+", type="+str(type))
		
		# Spends the MP
		var mp = current_entity.get_mp()
		current_entity.set_stats(MP, mp-skill.quantity)
		return StatsActionResult.new("Skill", current_entity, valid_targets, stat_change, dead, skill)
	
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
	$Interface.prepare_itens_action(Inventory)

func _on_Skills_button_down():
	var skills = current_entity.get_skills()
	LOADER.List = skills
	$Interface.prepare_skills_action(skills, current_entity.get_mp())

func _on_Attack_button_down():
	$Interface.prepare_attack_action()

func get_skitem(action_type: String, skitem_id: int) -> Item:
	if action_type == 'Item':
		return Inventory[skitem_id]
	elif action_type == 'Skill':
		return current_entity.get_skill(skitem_id)
	else:
		return null
