extends "Entity.gd"

func _init(valores, identificacao, habilidades):
	self.classe = "boss"
	self.stats = valores
	self.alive = true
	self.position = 0
	self.nome = identificacao
	self.skills = habilidades

func AI(player_list, enemies_list):
	var possible_target = -1
	for e in enemies_list:
		var status = e.get_status()
		for st in status:
			if st == "HP_CRITICAL":
				possible_target = e.id
				for i in range(self.skills.size()):
					var sk = self.skills[i]
					if sk.type == "RECOVERY" and self.get_mp() >= sk.get_cost():
						return ["Skills", [i, -(e.id+1)]]
	var max_hate = 0
	for p in player_list:
		if p.get_hate()[self.id] > max_hate:
			max_hate = p.get_hate()[self.id]
			possible_target = p.id
	
	if possible_target == -1:
		possible_target = floor(rand_range(0,player_list.size()))
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
		return ["Attack", possible_target]
	return ["Skills", [best_skill, possible_target]]

# Skills devem possuir tipos!
# Esda