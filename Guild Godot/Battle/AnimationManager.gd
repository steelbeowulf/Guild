extends Node2D

# Graphical stuff
var Players_img = []
var Enemies_img = []
var Players_status = []
var info = []
var Menu = null
var Info = null

var queue = []
var can_play = true
var global_animations = null
signal animation_finished

func initialize(Players, Enemies):
# Graphics stuff
	Menu = self.get_parent().get_node("Menu")
	Info = self.get_parent().get_node("Info")
	for i in range(len(Players)):
		var lane = Players[i].get_pos()
		var node = get_node("Players/P"+str(i))
		Players_img.append(node)
		node.change_lane(lane)
		node.set_animations(Players[i].sprite, Players[i].animations, Players[i])
		if not Players[i].is_dead():
			node.play("idle")
		else:
			node.play("dead")
		node.show()
		node.connect("finish_anim", self, "_on_animation_finished")
		Players[i].graphics = node
		Players[i].info = Info.get_node("P"+str(i))
		Players[i].info.set_initial_hp(Players[i].get_health(), Players[i].get_max_health())
		Players[i].info.set_initial_mp(Players[i].get_mp(), Players[i].get_max_mp())
	
	for i in range(len(Enemies)):
		var lane = Enemies[i].get_pos()
		var node = get_node("Enemies/E"+str(i))
		Enemies_img.append(node)
		node.set_animations(Enemies[i].sprite, Enemies[i].animations, Enemies[i])
		node.play("idle")
		node.show()
		node.connect("finish_anim", self, "_on_animation_finished")
		Enemies[i].graphics = node
	
	# Link target buttons with visual targets
	Menu.get_node("Attack").connect_targets(Players_img, Enemies_img, self)
	Menu.get_node("Skills").connect_targets(Players_img, Enemies_img, self)
	Menu.get_node("Itens").connect_targets(Players_img, Enemies_img, self)
	
	# Initializes player info on the UI
	Players_status = [Info.get_node("P0"), Info.get_node("P1"), Info.get_node("P2"), Info.get_node("P3")]
	for i in range(len(Players)):
		Players_status[i].set_name(Players[i].nome)
		Players_status[i].set_level(Players[i].level)
	
#	$Path2D.create_curve(Players_img[0].get_global_position(), Enemies_img[0].get_global_position(), 50)
	
	return [Players, Enemies]


func _on_animation_finished(anim):
	can_play = true
	if not queue:
		emit_signal("animation_finished")

func play(anim):
	var scope = anim[0]
	var animation_name = anim[1]
	var info = anim[2]

	if typeof(info) == TYPE_STRING and info != "ALL" and info != "LANE":
		can_play = false
	scope.play(animation_name, info)

func enqueue(scope, animation_name, additional_info):
	queue.push_front([scope, animation_name, additional_info])

func _physics_process(delta):
	if queue and can_play:
		var current_animation = queue.pop_back()
		play(current_animation)
	if not queue and can_play:
		emit_signal("animation_finished")

func resolve(current_entity, action, target, result, bounds, next):
	# TODO Deal with ailments
	if typeof(action) == TYPE_STRING:
		if action == "Attack":
			var dies_on_attack = result[0]
			var dmg = result[1]
			$Log.display_text("Attack")
			enqueue(current_entity.graphics, "attack", null) # ataque do current_entity
			enqueue(target.graphics, "Damage", dmg) # dano no alvo
			#enqueue(target.graphics, "Damage", dmg) # valor do dano
			if target.tipo == 'Player':
				enqueue(target.info, "UpdateHP", dmg) # lifebar
			if dies_on_attack:
				enqueue(target.graphics, "death", null) #death animaton
				target.graphics
		
		#[targets, skill.quantity, [dead, ailments, stats_change]]
		elif action == "Skills":
			var targets = target[0]
			var mp = target[1]
			var dies_on_attack = result[0]
			var ailments = result[1]
			var stats = result[2]
			

			#$Log.display_text("")
			enqueue(current_entity.graphics, "skill", null) # ataque do current_entity
			#enqueue(target[0].graphics, "Damage", dmg) # dano no alvo
			#enqueue(target.graphics, "Damage") # dano no alvo
			#enqueue(target.graphics, "Damage", dmg) # valor do dano
			#enqueue(info[target], target, null) # lifebar

			if current_entity.tipo == 'Player':
				enqueue(current_entity.info, "UpdateMP", mp)
			for i in range(len(targets)):
				if targets[i].tipo == 'Player':
					for st in stats[i]:
						#enqueue(targets[i].graphics, "Damage") # dano no alvo
						enqueue(targets[i].info, "UpdateHP", st[0]) # lifebar
				if dies_on_attack[i]:
					enqueue(targets[i].graphics, "death", null) #death animaton

		
		elif action == "Lane":
			var lane = result
			$Log.display_text("Lane change")
			current_entity.graphics.change_lane(lane)
			#emit_signal("animation_finished")
		
		elif action == "Run":
			var is_boss = result[0]
			var run_successful = result[1]
			if not is_boss and run_successful:
				$Log.display_text("Ran away safely")
				enqueue(current_entity.graphics, "Run", null) #run animation
			elif is_boss:
				$Log.display_text("Can't escape")
			else:
				$Log.display_text("Failed to run")
	else:
		var dead_people_list = result[0]
		var all_ailments = result[1]
		var stats_change = result[2]
		
#		for ailment in all_ailments:
#			enqueue(target.graphics, ailment, action.target) #ailment effect anim
#		for stat_change in stats_change:
#			enqueue(target.graphics, stat_change, action.target) #stat effect anim
#		for dead in dead_people_list:
#			enqueue(dead.graphics, "death", null) #kill people

	current_entity.graphics.end_turn()
	next.graphics.turn()
	# TODO MUDAR bounds should be on the logical part
	#for i in range(len(Players_img)):
	#	Players_img[i].update_bounds(bounds)

# TODO: there are graphical parts in this, move to ANimationManager
func manage_hate(type, target):
	var max_hate = -1
	var index = -1
	if type == 0:
		# Focus entered
		for i in range(len(Players_img)):
			#var img = Players_img[i]
			var p = Players_img[i]
			if p.data.hate[target] >= max_hate:
				max_hate = p.data.hate[target]
				index = i
			#img.display_hate(p.data.hate[target], target)
		$Path2D.create_curve(Enemies_img[target].get_global_position(), Players_img[index].get_global_position(), 32)


func hide_hate():
	$Path2D.destroy_curve()