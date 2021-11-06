# Manages the animation of all 2D sprites on battle
# Also responsible for making the path between an enemy and its
# current target
extends Node2D

signal animation_finished

# Initialization
var players_graphics = []
var enemies_graphics = []
var players_statuses = []

# Animation Queue
var queue = []
var last = false
var can_play = true
var entering = true

# Shortcuts
onready var menu_node = self.get_parent().get_node("Interface/menu_node")
onready var info_node = self.get_parent().get_node("Interface/info_node")


# Initializes players and enemies sprites on battle, loads their animation,
# sets themselves as targets for actions setup player info on the bottom menu
func initialize(players: Array, enemies: Array):
	var i = 0
	for node in get_node("Players").get_children():
		if i < len(players):
			var lane = players[i].get_pos()
			players_graphics.append(node)
			node.change_lane(lane)
			node.set_animations(players[i].sprite, players[i].animations, players[i])
			node.connect("finish_anim", self, "_on_animation_finished")
			players[i].graphics = node
			players[i].info = info_node.get_node("P" + str(i))
			players[i].info.set_initial_hp(players[i].get_stat("HP"), players[i].get_stat("HP_MAX"))
			players[i].info.set_initial_mp(players[i].get_stat("MP"), players[i].get_stat("MP_MAX"))
			players[i].info.connect("finish_anim", self, "_on_animation_finished")
			i += 1
			node.enter_scene()
		else:
			node.hide()
	i = 0
	for node in get_node("Enemies").get_children():
		if i < len(enemies):
			enemies_graphics.append(node)
			node.set_animations(enemies[i].sprite, enemies[i].animations, enemies[i])
			node.play("move")
			node.show()
			node.connect("finish_anim", self, "_on_animation_finished")
			enemies[i].graphics = node
			i += 1
			node.enter_scene()
		else:
			node.hide()

	# Link target buttons with visual targets
	var all_players = get_node("Players")
	var all_enemies = get_node("Enemies")
	menu_node.get_node("Attack").connect_targets(
		players_graphics, enemies_graphics, self, all_players, all_enemies
	)
	menu_node.get_node("Skill").connect_targets(
		players_graphics, enemies_graphics, self, all_players, all_enemies
	)
	menu_node.get_node("Item").connect_targets(
		players_graphics, enemies_graphics, self, all_players, all_enemies
	)

	# Initializes player info on the UI
	players_statuses = [
		info_node.get_node("P0"),
		info_node.get_node("P1"),
		info_node.get_node("P2"),
		info_node.get_node("P3")
	]
	for i in range(len(players)):
		players_statuses[i].set_name(players[i].name)
		players_statuses[i].set_level(players[i].level)

	return [players, enemies]


################ Animation Queue


# Called every frame: processes the animation queue
# Plays next animation on queue if there is one, or
# sends the animation_finished signal
func _physics_process(_delta: float):
	if queue and can_play:
		var current_animation = queue.pop_back()
		can_play = false
		play(current_animation)
	elif not queue and last and not entering:
		last = false
		emit_signal("animation_finished")
	elif not queue:
		last = true


# Called when an animation finishes
func _on_animation_finished(animation_name: String):
	print("[ANIMATION MANAGER] finished animation " + animation_name)
	can_play = true
	if last or animation_name == "Entrance":
		emit_signal("animation_finished")


# TODO: Make anim class
# Plays an animation
# Anim parameter has three elements:
# anim[0] = scope = Node that has a play method
# anim[1] = animation_name = Animation name
# anim[2] = info = Additional animation parameters
func play(anim: Array):
	print("[ANIMATON MANAGER] playing animation " + anim[1])
	var scope = anim[0]
	var animation_name = anim[1]
	var info = anim[2]
	if typeof(info) == TYPE_STRING and (info == "ALL" or info == "LANE"):
		can_play = true
	scope.play(animation_name, info)


# TODO: Use anim class
# Adds an animation to the queue
func enqueue(scope: Node, animation_name: String, additional_info):
	print("[ANIMATION PLAYER] Adding " + animation_name + " to queue")
	queue.push_front([scope, animation_name, additional_info])


# Resolves a turn from battle according to the action taken
# Enqueues all necessary animations
func resolve(current_entity: Entity, action_result: ActionResult):
	print("[ANIMATION PLAYER] Resolving current turn")
	last = false
	var action_type = action_result.get_type()
	# TODO Deal with ailments
	if action_type == "Pass":
		pass
	elif action_type == "Attack" || action_type == "Miss" || action_type == "Critical Attack":
		$Log.display_text("Attack")
		var target = action_result.get_targets()[0]
		var dies = action_result.get_deaths()[0]
		var dmg = action_result.get_stats_change()[0]
		enqueue(current_entity.graphics, "attack", null)  # current_entity attack
		if action_type == "Attack":
			enqueue(target.graphics, "Damage", dmg)  # target damaged
		elif action_type == "Miss":
			enqueue(target.graphics, "Miss", dmg)  # target missed
		elif action_type == "Critical Attack":
			enqueue(target.graphics, "Critical", dmg)  # target critical hit
		if target.type == "Player":
			enqueue(target.info, "UpdateHP", dmg)  # HP bar
		if dies:
			enqueue(target.graphics, "death", null)  # Death animation
	elif action_type == "Lane":
		$Log.display_text("Lane change")
		var lane = action_result.get_lane()
		current_entity.graphics.change_lane(lane)
	elif action_type == "Run":
		var is_boss = action_result.is_boss()
		var is_run_successful = action_result.is_run_successful()
		if not is_boss and is_run_successful:
			$Log.display_text("Ran away safely")
		elif is_boss:
			$Log.display_text("Can't escape")
		else:
			$Log.display_text("Failed to run")
		emit_signal("animation_finished")
	else:
		var skitem = action_result.get_spell()
		$Log.display_text(skitem.name)
		var targets = action_result.get_targets()
		var dies_on_attack = action_result.get_deaths()
		var stats = action_result.get_stats_change()
		enqueue(current_entity.graphics, "skill", null)  # current_entity attack
		for i in range(len(targets)):
			var graphics = targets[i].graphics
			if action_type == "Skill":
				graphics.set_spell(skitem.img, skitem.anim, skitem.name)
				enqueue(graphics, skitem.name, "Skill")  # spell animation
			enqueue(graphics, "Damage", stats[i])  # take damage
			if dies_on_attack[i]:
				enqueue(graphics, "death", null)  # death animation
			if targets[i].type == "Player":
				for st in stats[i]:
					enqueue(targets[i].info, "UpdateHP", st[0])  # HP bar
		if current_entity.type == "Player" and action_type == "Skill":
			var mp = skitem.get_cost()
			enqueue(current_entity.info, "UpdateMP", mp)  # MP bar
	enqueue(current_entity.graphics, "end_turn", [])


################ Reinforcements


# Adds new player sprite into current battle
func add_player(p: Player):
	var last_index = players_graphics.size()
	var node = get_node("Players").get_child(last_index)
	players_graphics.append(node)
	node.change_lane(p.get_pos())
	node.set_animations(p.sprite, p.animations, p)
	entering = true
	node.connect("finish_anim", self, "_on_animation_finished")
	p.graphics = node
	p.info = info_node.get_node("P" + str(last_index))
	p.info.set_initial_hp(p.get_stat("HP"), p.get_stat("HP_MAX"))
	p.info.set_initial_mp(p.get_stat("MP"), p.get_stat("MP_MAX"))
	p.info.connect("finish_anim", self, "_on_animation_finished")
	players_statuses[last_index].set_name(p.get_name())
	players_statuses[last_index].set_level(p.get_level())
	menu_node.get_node("Attack").connect_target_player(node)
	menu_node.get_node("Skill").connect_target_player(node)
	menu_node.get_node("Item").connect_target_player(node)
	node.enter_scene()


# Adds new enemy sprite into current battle
func add_enemy(e: Enemy):
	var last_index = enemies_graphics.size()
	var node = get_node("Enemies").get_child(last_index)
	enemies_graphics.append(node)
	node.set_animations(e.sprite, e.animations, e)
	entering = true
	node.connect("finish_anim", self, "_on_animation_finished")
	e.graphics = node
	menu_node.get_node("Attack").connect_target_enemy(node, self, last_index)
	menu_node.get_node("Skill").connect_target_enemy(node, self, last_index)
	menu_node.get_node("Item").connect_target_enemy(node, self, last_index)
	node.enter_scene()


################ Hate


# Updates visual representation of enemy targetting
# type: Attack type (?) 0 if HP damage
# target: Enemy index currently selected by player
func manage_hate(type: int, target: int):
	var index = enemies_graphics[target].data.get_target()
	if index < 0:
		index = -(index + 1)
	if type == 0:
		$Path2D.create_curve(
			enemies_graphics[target].get_global_position(),
			players_graphics[index].get_global_position(),
			32
		)


# Hides visual representation of enemy targetting
func hide_hate():
	$Path2D.destroy_curve()
