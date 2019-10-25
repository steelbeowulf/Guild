extends Node2D

# Graphical stuff
var Players_img = []
var Enemies_img = []
var Players_status = []
var info = []

var queue = []
var can_play = true
var global_animations = null

func initialize(Players, Enemies):
# Graphics stuff
	for i in range(len(Players)):
		var lane = Players[i].get_pos()
		var node = get_node("Players/P"+str(i))
		Players_img.append(node)
		node.parent = self
		node.change_lane(lane)
		node.set_animations(Players[i].sprite, Players[i].animations)
		node.play_animation("idle")
		node.show()
		Players[i].graphics = node
	
	for i in range(len(Enemies)):
		var lane = Enemies[i].get_pos()
		var node = get_node("Enemies/E"+str(i))
		Enemies_img.append(node)
		node.parent = self
		node.set_animations(Enemies[i].sprite, Enemies[i].animations)
		node.play_animation("idle")
		node.show()
		Enemies[i].graphics = node
	
	# Link target buttons with visual targets
	$Menu/Attack.connect_targets(Players_img, Enemies_img, self)
	$Menu/Skills.connect_targets(Players_img, Enemies_img, self)
	$Menu/Itens.connect_targets(Players_img, Enemies_img, self)
	
	# Initializes player info on the UI
	Players_status = [get_node("Info/P0"), get_node("Info/P1"), get_node("Info/P2"), get_node("Info/P3")]
	for i in range(len(Players)):
		Players_status[i].set_name(Players[i].nome)
		Players_status[i].set_level(Players[i].level)


func _on_animation_finished(anim):
	can_play = true

func play(anim):
	var scope = anim[0]
	var animation_name = anim[1] 
	var info = anim[2]
	if info != "ALL" and info != "LANE":
		can_play = false
	scope.play(animation_name, info)

func enqueue(scope, animation_name, additional_info):
	queue.push_front([scope, animation_name, additional_info])

func _physics_process(delta):
	if queue and can_play:
		var current_animation = queue.pop_back()
		play(current_animation)

func resolve(current_entity, action, target, result, bounds):
	# TODO Deal with ailments
	if typeof(action) == TYPE_STRING:
		if action == "Attack":
			var dies_on_attack = result[0]
			var dmg = result[1]
			$Logs.set_text("Attack")
			enqueue(current_entity.graphics, "Attack", null) # ataque do current_entity
			#enqueue(target.graphics, "Damage") # dano no alvo
			enqueue(target.graphics, "Damage", dmg) # valor do dano
			enqueue(info[target], target, null) # lifebar
			if dies_on_attack:
				enqueue(target.graphics, "Death", null) #death animaton
		
		elif action == "Lane":
			var lane = result
			$Logs.set_text("Lane change")
			current_entity.graphics.change_lane(lane)
		
		elif action == "Run":
			var is_boss = result[0]
			var run_successful = result[1]
			if not is_boss and run_successful:
				$Logs.set_text("Ran away safely")
				enqueue(global_animations, "Run", null) #run animation
			elif is_boss:
				$Logs.set_text("Can't escape")
			else:
				$Logs.set_text("Failed to run")
	else:
		var dead_people_list = result[0]
		var all_ailments = result[1]
		var stats_change = result[2]
		
		for ailment in all_ailments:
			enqueue(target.graphics, ailment, action.target) #ailment effect anim
		for stat_change in stats_change:
			enqueue(target.graphics, stat_change, action.target) #stat effect anim
		for dead in dead_people_list:
			enqueue(dead.graphics, "Death", null) #kill people

	# TODO MUDAR bounds should be on the logical part
	for i in range(len(Players_img)):
		Players_img[i].update_bounds(bounds)