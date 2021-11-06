class_name Player
extends Entity

const EQUIP_DICT = {"HEAD": 0, "BODY": 1, "WEAPON": 2, "ACCESSORY1": 3, "ACCESSORY2": 4}

var hate = []
var multiplier = [0.5, 1.0, 3.0]
var equipments = []
var jobs = []
var possible_skills = {}

var portrait


func _init(
	id: int,
	lv: int,
	experience: int,
	img: str,
	portrait: str,
	animations: Dictionary,
	stats: Array,
	position: int,
	name: str,
	skills: Array,
	equipments: Array,
	resistances: Dictionary,
	jobs: Dictionary
):
	self.id = id
	self.sprite = img
	self.animations = anim
	self.portrait = portrait
	self.level = lv
	self.experience = experience
	self.stats = stats
	self.position = position
	self.name = nome
	self.skills = []
	learn_correct_skills(classes[0].get_level(), classes[0].get_skills())
	learn_correct_skills(self.level, skills)
	self.possible_skills = skills
	self.equipments = equipments
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0
	self.type = "Player"
	self.jobs = jobs


func save_data():
	var dict = {}
	dict["ID"] = id
	dict["LEVEL"] = level
	dict["EXPERIENCE"] = experience
	dict["IMG"] = get_sprite()
	dict["ANIM"] = get_animation()
	dict["PORTRAIT"] = get_portrait()
	dict["HP"] = get_stat("HP")
	dict["HP_MAX"] = get_stat("HP_MAX")
	dict["MP"] = get_stat("MP")
	dict["MP_MAX"] = get_stat("MP_MAX")
	dict["ATK"] = get_stat("ATK")
	dict["ATKM"] = get_stat("ATKM")
	dict["DEF"] = get_stat("DEF")
	dict["DEFM"] = get_stat("DEFM")
	dict["AGI"] = get_stat("AGI")
	dict["ACC"] = get_stat("ACC")
	dict["EVA"] = get_stat("EVA")
	dict["LCK"] = get_stat("LCK")
	dict["LANE"] = 0
	dict["NAME"] = get_name()
	dict["SKILLS"] = get_skill_ids()
	dict["EQUIPS"] = get_equip_ids()
	dict["RESISTANCE"] = get_resistance()
	dict["JOBS"] = get_jobs()
	return dict


func get_sprite():
	return self.sprite


func get_animation():
	return self.animations


func get_portrait():
	return self.portrait


func get_skills():
	return self.skills


func get_possible_skills():
	return self.possible_skills


func get_equips():
	return self.equipments


func get_skill_ids():
	var ids = []
	for skill in get_skills():
		ids.append(skill.id)
	return ids


func get_equip_ids():
	var ids = []
	for equip in get_equips():
		if equip != null:
			ids.append(equip.id)
		else:
			ids.append(-1)
	return ids


func unequip(equipment: Equiment, slot = -1):
	print("Unequipping ", equipment.get_name(), " on ", self.get_name())
	if slot == -1:
		if equipment.location == "ACCESSORY":
			if self.equipments[3]:
				slot = 3
			elif self.equipments[4]:
				slot = 4
		else:
			slot = EQUIP_DICT[equipment.location]
	for effect in self.equipments[slot].get_effects():
		self.stats[effect.get_id()] -= effect.get_value()
	self.equipments[slot].equipped = -1
	self.equipments[slot] = null


func equip(equipment: Equipment, slot = -1):
	print("Equipping ", equipment.get_name(), " on ", self.get_name())
	if slot == -1:
		if equipment.location == "ACCESSORY":
			if not self.equipments[3]:
				slot = 3
			elif not self.equipments[4]:
				slot = 4
		else:
			slot = EQUIP_DICT[equipment.location]
	if self.equipments[slot]:
		self.unequip(self.equipments[slot], slot)
	self.equipments[slot] = equipment
	equipment.equipped = id
	print("Agora " + str(slot) + " tem um " + self.equipments[slot].get_name())
	for effect in self.equipments[slot].get_effects():
		self.stats[effect.get_id()] += effect.get_value()


func get_equip(location: String):
	if location == "ACCESSORY":
		if self.equipments[3]:
			return self.equipments[3]
		if self.equipments[4]:
			return self.equipments[4]
		return null
	var slot = EQUIP_DICT[location]
	return self.equipments[slot]


func get_resistance():
	return self.resist


func get_resist(type):
	return self.resist[type]


func get_hate():
	return self.hate


# Return current (active) job
func get_job():
	return self.jobs[0].get_name()


func get_jobs():
	return self.jobs


func zero_hate():
	for i in range(len(hate)):
		hate[i] = 0


func reset_hate():
	hate = []


func die():
	print("[PLAYER] " + self.name + " has died!")
	self.set_stat(HP, 0)
	self.remove_all_status()
	self.status["KO"] = [9999, 9999]
	self.dead = true
	self.zero_hate()


func update_hate(dmg, enemy):
	self.hate[enemy] += multiplier[position] * abs(dmg)
	return self.hate


func learn_correct_skills(current_level: int, skills_arg: Dictionary):
	for s in skills_arg.keys():
		if s <= current_level:
			learn_skill(skills_arg[s])


func get_experience_to_level_up():
	return ceil(pow(1.8, self.level) * 5.0)


func gain_experience(experience: int):
	var leveled_up = 0
	var level_up_dict = {"skills": []}
	self.experience += experience
	var xp_to_level_up = get_experience_to_level_up()

	while self.experience >= xp_to_level_up:
		level_up_dict = self.level_up(level_up_dict)
		self.experience -= xp_to_level_up
		xp_to_level_up = get_experience_to_level_up()
		leveled_up += 1
	return [leveled_up, level_up_dict]


func has_skill(id: int):
	for sk in self.skills:
		if sk.id == id:
			return true
	return false


func learn_skill(skill: Skill):
	if not has_skill(skill.id):
		self.skills.append(skill)
		return skill


func level_up(level_up_dict: Dictionary):
	self.level += 1
	# Learn new skills from job
	var current_job_skills = self.jobs[0].get_skills()
	if current_job_skills.has(self.level):
		var skill = learn_skill(current_job_skills[self.level])
		if skill:
			level_up_dict["skills"].append(skill)

	# Learn new skills from character
	var character_skills = self.get_possible_skills()
	if character_skills.has(self.level):
		var skill = learn_skill(character_skills[self.level])
		if skill:
			level_up_dict["skills"].append(skill)

	# Raise stats according to job
	var stat_raise_chance = self.jobs[0].get_proficiencies()
	randomize()
	for stat in stat_raise_chance.keys():
		var stat_key = DSTAT[stat]
		var stat_up = 0
		if stat_raise_chance[stat]:
			stat_up += floor(rand_range(2, 5))
		else:
			stat_up += floor(rand_range(1, 3))
		self.set_stat(stat_key, self.get_stats(stat_key) + stat_up)
		if level_up_dict.has(stat_key):
			level_up_dict[stat] += stat_up
		else:
			level_up_dict[stat] = stat_up
	return level_up_dict


func clone():
	var new_stats = [] + self.stats
	return self.get_script().new(
		self.id,
		self.level,
		self.experience,
		self.sprite,
		self.animations,
		new_stats,
		self.position,
		self.name,
		self.skills,
		self.equipments,
		self.resist
	)
