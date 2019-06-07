extends "Entity.gd"

func _init(id, lv, experience, img, valores, identificacao, habilidades, resistances):
	self.id = id
	self.level = int(lv)
	self.xp = int(experience)
	self.sprite = img
	self.classe = "boss"
	self.stats = valores
	self.alive = true
	self.position = 0
	self.nome = identificacao
	self.skills = habilidades
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0

func AI(player_list, enemies_list):
	var possible_target = -1
	for e in enemies_list:
		if not e.is_dead():
			var status = e.get_status()
			for st in status:
				if st == "HP_CRITICAL":
					for i in range(self.skills.size()):
						var sk = self.skills[i]
						if sk.type == "RECOVERY" and self.get_mp() >= sk.get_cost():
							return ["Skills", [i, -(e.index)]]
	var max_hate = 0
	for p in player_list:
		if p.get_hate()[self.index] > max_hate:
			max_hate = p.get_hate()[self.index]
			possible_target = p.index
	if possible_target < 0:
		print("VOU ESCOLHER ALEATÓRIO")
		randomize()
		possible_target = floor(rand_range(0,player_list.size()-1))
		while player_list[possible_target].is_dead():
			randomize()
			possible_target = floor(rand_range(0,player_list.size()-1))
	print("ESCOLHI "+player_list[possible_target].get_name())
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
		return ["Attack", possible_target+1]
	return ["Skills", [best_skill, possible_target+1]]

func get_xp():
	return self.xp
	
func enemy_duplicate():
	return self.get_script().new(self.id, self.level, self.xp, 
	self.sprite, self.stats, self.nome, self.skills, self.resist)
