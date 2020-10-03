extends "Entity.gd"

var target : int

func _init(id, lv, experience, img, animation, valores, identificacao, habilidades, resistances):
	self.id = id
	self.level = int(lv)
	self.xp = int(experience)
	self.sprite = img
	self.animations = animation
	self.classe = "boss"
	self.stats = valores
	self.alive = true
	self.position = 0
	self.nome = identificacao
	self.skills = habilidades
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0
	self.tipo = "Enemy"
	self.target = -1

func AI(player_list, enemies_list) -> Action:
	var possible_target = -1
	for e in enemies_list:
		if not e.is_dead():
			var status = e.get_status()
			for st in status:
				if st == "HP_CRITICAL":
					for i in range(self.skills.size()):
						var sk = self.skills[i]
						if sk.type == "RECOVERY" and self.get_mp() >= sk.get_cost():
							return Action.new("Skill", i, [e.index])

	possible_target = get_target()

	var best_skill = -1
	var best_dmg = 0
	for i in range(self.skills.size()):
		var sk = self.skills[i]
		if sk.type == "OFFENSE":
			for ef in sk.effect:
				if ef[0] == HP and ef[1] < best_dmg and self.get_mp() >= sk.get_cost():
					best_dmg = ef[1]
					best_skill = i
	if best_skill == -1:
		return Action.new("Attack", 1, [-possible_target])
	return Action.new("Skill", best_skill, [-possible_target])

func sum(array: Array):
	var total = 0
	for i in array:
		total += i
	return total

func get_xp():
	return self.xp

func get_target():
	return self.target

func update_target(player_list):
	var max_self_hate = 0
	var max_accumulated_hate = 0
	var alternative_target = -1
	var possible_target = -1
	for p in player_list:
		if p.get_hate()[self.index] > max_self_hate:
			max_self_hate = p.get_hate()[self.index]
			possible_target = p.index
		if sum(p.get_hate()) > max_accumulated_hate:
			max_accumulated_hate = sum(p.get_hate())
			alternative_target = p.index

	if possible_target == -1:
		possible_target = alternative_target
		if possible_target == -1:
			randomize()
			possible_target = int(rand_range(0,player_list.size()))
			while player_list[possible_target].is_dead():
				randomize()
				possible_target = int(rand_range(0,player_list.size()))
	
	self.target = possible_target

func _duplicate():
	var new_stats = [] + self.stats
	return self.get_script().new(self.id, self.level, self.xp, 
	self.sprite, self.animations, new_stats, self.nome, self.skills, self.resist)
