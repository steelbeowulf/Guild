extends Node2D

# Graphical stuff
var Players_img = []
var Enemies_img = []
var Players_status = []
var info = []
var Menu = null
var Info = null
var timer = 0.0

var queue = []
var can_play = true
var global_animations = null
signal animation_finished

func initialize(Players, Enemies):
# Graphics stuff
	Menu = self.get_parent().get_node("Interface/Menu")
	Info = self.get_parent().get_node("Interface/Info")
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
	Menu.get_node("Skill").connect_targets(Players_img, Enemies_img, self)
	Menu.get_node("Item").connect_targets(Players_img, Enemies_img, self)
	
	# Initializes player info on the UI
	Players_status = [Info.get_node("P0"), Info.get_node("P1"), Info.get_node("P2"), Info.get_node("P3")]
	for i in range(len(Players)):
		Players_status[i].set_name(Players[i].nome)
		Players_status[i].set_level(Players[i].level)
	
	return [Players, Enemies]


func _on_animation_finished(anim):
	print("[ANIMATION MANAGER] finished animation "+anim)
	can_play = true
	if not queue:
		emit_signal("animation_finished")

func play(anim):
	print("[ANIMATON MANAGER] playing animation "+anim[1])
	var scope = anim[0]
	var animation_name = anim[1]
	var info = anim[2]

	if typeof(info) == TYPE_STRING and info != "ALL" and info != "LANE":
		can_play = false
	scope.play(animation_name, info)

func enqueue(scope, animation_name, additional_info):
	print("[ANIMATION PLAYER] Adding "+animation_name+" to queue")
	queue.push_front([scope, animation_name, additional_info])

func _physics_process(delta):
	if queue and can_play:
		var current_animation = queue.pop_back()
		play(current_animation)
	if not queue and can_play:
		emit_signal("animation_finished")

func resolve(current_entity: Entity, action_result):
	print("[ANIMATION PLAYER] Resolving current turn")
	var action_type = action_result.get_type()
	# TODO Deal with ailments
	if action_type == "Pass":
		return
	elif action_type == "Attack":
		$Log.display_text("Attack")
		var target = action_result.get_targets()[0]
		var dies = action_result.get_deaths()[0]
		var dmg = action_result.get_stats_change()[0]
		enqueue(current_entity.graphics, "attack", null) # ataque do current_entity
		enqueue(target.graphics, "Damage", dmg) # dano no alvo
		if target.tipo == 'Player':
			enqueue(target.info, "UpdateHP", dmg) # lifebar
		if dies:
			enqueue(target.graphics, "death", null) #death animation
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
	else:
		var skitem = action_result.get_spell()
		$Log.display_text(skitem.nome)
		var targets = action_result.get_targets()
		var dies_on_attack = action_result.get_deaths()
		var stats = action_result.get_stats_change()
		enqueue(current_entity.graphics, "skill", null) # ataque do current_entity
		for i in range(len(targets)):
			var graphics = targets[i].graphics
			if action_type == "Skill":
				graphics.set_spell(skitem.img, skitem.anim, skitem.nome)
				enqueue(graphics, skitem.nome, 'Skill') #spell anim
			enqueue(graphics, "Damage", stats[i]) #take damage
			if dies_on_attack[i]:
				enqueue(graphics, "death", null) #death animaton
			if targets[i].tipo == 'Player':
				for st in stats[i]:
					enqueue(targets[i].info, "UpdateHP", st[0]) # lifebar
		if current_entity.tipo == "Player" and action_type == "Skill":
			var mp = skitem.get_cost()
			enqueue(current_entity.info, "UpdateMP", mp) # manabar

	current_entity.graphics.end_turn()

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