extends "Entity.gd"
class_name Enemy

var target : int = -10
var action: Action = null

var turns : int = 0

func _init(id, lv, experience, img, animation, valores, identificacao, habilidades, resistances):
	self.id = id
	self.level = int(lv)
	self.xp = int(experience)
	self.sprite = img
	self.animations = animation
	self.classe = "boss"
	self.stats = valores
	self.position = 0
	self.nome = identificacao
	self.skills = habilidades
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0
	self.tipo = "Enemy"
	self.target = -10

func AI(player_list: Array, enemies_list: Array) -> Action:
	# Get previously defined target
	var target = get_target()
	
	turns -= 1
	if turns == 0:
		self.action = null
	
	# Get previously defined action and execute it if exists
	var action = get_action()
	if action != null:
		return action
	
	# Check if allies need healing
	for e in enemies_list:
		if not e.is_dead():
			var status = e.get_status()
			for st in status:
				if st == "HP_CRITICAL":
					for i in range(self.skills.size()):
						var sk = self.skills[i]
						if sk.type == "RECOVERY" and self.get_mp() >= sk.get_cost():
							return Action.new("Skill", i, [e.index])

	# Try to use skill with highest damage
	var best_skill = -1
	var best_dmg = 0
	for i in range(self.skills.size()):
		var sk = self.skills[i]
		if sk.type == "OFFENSE":
			for ef in sk.effect:
				if ef.get_id() == HP and ef.get_value() < best_dmg and self.get_mp() >= sk.get_cost():
					best_dmg = ef.get_value()
					best_skill = i
	if best_skill != -1:
		return Action.new("Skill", best_skill, [target])
	
	# Not enough MP, simply use attack
	return Action.new("Attack", 1, [target])


func sum(array: Array):
	var total = 0
	for i in array:
		total += i
	return total

func get_xp():
	return self.xp

func get_target():
	return self.target

func get_action():
	return self.action

func set_next_action(action_arg: Action, number_of_turns = 1):
	self.action = action_arg
	for i in range(len(self.action.targets)):
		self.action.targets[i] = -(self.action.targets[i] + 1)
	self.turns = number_of_turns

func set_next_target(player_id: int, number_of_turns = 1):
	self.target = player_id
	self.turns = number_of_turns

func update_target(player_list: Array, enemy_list: Array):
	turns -= 1
	if turns > 0:
		var target = self.target
		if self.action != null and len(self.action.targets) == 1:
			target = self.action.targets[0]
		var index = target
		var list = enemy_list
		if self.target < 0 and self.target != -10:
			index = -(target + 1)
			list = player_list
		if not list[index].dead:
			print("[AI "+self.nome+"] won't update target")
			return
		else:
			turns = 0
			self.action = null

	var max_self_hate = 0
	var max_accumulated_hate = 0
	var alternative_target = -10
	var possible_target = -10
	for p in player_list:
		if p.get_hate()[self.index] > max_self_hate:
			max_self_hate = p.get_hate()[self.index]
			possible_target = p.index
		if sum(p.get_hate()) > max_accumulated_hate:
			max_accumulated_hate = sum(p.get_hate())
			alternative_target = p.index

	if possible_target == -10:
		possible_target = alternative_target
		if possible_target == -10:
			randomize()
			possible_target = int(rand_range(0,player_list.size()))
			while player_list[possible_target].is_dead():
				randomize()
				possible_target = int(rand_range(0,player_list.size()))
	
	self.target = -(possible_target + 1)

func _duplicate():
	var new_stats = [] + self.stats
	return self.get_script().new(self.id, self.level, self.xp, 
	self.sprite, self.animations, new_stats, self.nome, self.skills, self.resist)
