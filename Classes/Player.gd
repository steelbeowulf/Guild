extends "Entity.gd"

var hate = []
var multiplier = [0.5, 1.0, 3.0]

var portrait

func _init(id, lv, experience, img, port, anim, valores,  pos, identificacao, habilidades, resistances):
	self.id = id
	self.sprite = img
	self.animations = anim
	self.portrait = port
	self.level = int(lv)
	self.xp = int(experience)
	self.stats = valores
	self.position = pos
	self.nome = identificacao
	self.skills = habilidades
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0
	self.tipo = "Player"

func save_data():
	var dict = {}
	dict["ID"] = id
	dict["LEVEL"] = level
	dict["EXPERIENCE"] = xp
	dict["IMG"] = get_sprite()
	dict["ANIM"] = get_animation()
	dict["PORTRAIT"] = get_portrait()
	dict["HP"] = get_health()
	dict["HP_MAX"] = get_max_health()
	dict["MP"] = get_mp()
	dict["MP_MAX"] = get_max_mp()
	dict["ATK"] = get_atk()
	dict["ATKM"] = get_atkm()
	dict["DEF"] = get_def()
	dict["DEFM"] = get_defm()
	dict["AGI"] = get_agi()
	dict["ACC"] = get_acc()
	dict["EVA"] = get_eva()
	dict["LCK"] = get_lck()
	dict["LANE"] = 0 # TODO
	dict["NAME"] = get_name()
	dict["SKILLS"] = get_skill_ids()
	dict["RESISTANCE"] = get_resistance()
	return dict

func get_sprite():
	return self.sprite

func get_animation():
	return self.animations

func get_portrait():
	return self.portrait

func get_skills():
	return self.skills

func get_skill_ids():
	var ids = []
	for skill in get_skills():
		ids.append(skill.id)
	return ids

func get_resistance():
	return self.resist

func get_resist(type):
	return self.resist[type]

func get_hate():
	return self.hate

func zero_hate():
	for i in range(len(hate)):
		hate[i] = 0

func reset_hate():
	hate = []

func die():
	print("OH NO, "+self.nome+" HAS DIED!")
	self.set_stats(HP, 0)
	self.remove_all_status()
	self.status["KO"] = [9999, 9999]
	self.dead = true
	self.zero_hate()

func update_hate(dmg, enemy):
	self.hate[enemy] += multiplier[position]*abs(dmg)
	return self.hate

func _duplicate():
	var new_stats = [] + self.stats
	return self.get_script().new(self.id, self.level, self.xp, 
	self.sprite, self.animations, new_stats, self.position, self.nome, self.skills, self.resist)
