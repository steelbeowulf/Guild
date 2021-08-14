extends "Entity.gd"

const equip_dict = {'HEAD':0, 'BODY':1, 'WEAPON':2, 'ACCESSORY1':3, 'ACCESSORY2':4}

var hate = []
var multiplier = [0.5, 1.0, 3.0]
var equips = [] # Head, Body, Hands, Acc1, Acc2
var job

var portrait

func _init(id, lv, experience, img, port, anim, valores,  pos, identificacao, habilidades, equipamentos, resistances, classe):
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
	self.equips = equipamentos
	self.resist = resistances
	self.resist["PHYSIC"] = 1.0
	self.resist["MAGIC"] = 1.0
	self.tipo = "Player"
	self.job = classe

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
	dict["LANE"] = 0
	dict["NAME"] = get_name()
	dict["SKILLS"] = get_skill_ids()
	dict["EQUIPS"] = get_equip_ids()
	dict["RESISTANCE"] = get_resistance()
	dict["CLASS"] = get_job()
	return dict

func get_sprite():
	return self.sprite

func get_animation():
	return self.animations

func get_portrait():
	return self.portrait

func get_skills():
	return self.skills

func get_equips():
	return self.equips

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


func unequip(equipament, slot=-1):
	print("Unequipping ", equipament.get_name(), " on ", self.get_name())
	if slot == -1:
		if equipament.location == "ACCESSORY":
			if self.equips[3]:
				slot = 3
			elif self.equips[4]:
				slot = 4
		else:
			slot = equip_dict[equipament.location]
	for effect in self.equips[slot].get_effects():
		self.stats[effect.get_id()] -= effect.get_value()
	self.equips[slot].equipped = -1
	self.equips[slot] = null


func equip(equipament, slot=-1):
	print("Equipping ", equipament.get_name(), " on ", self.get_name())
	if slot == -1:
		if equipament.location == "ACCESSORY":
			if not self.equips[3]:
				slot = 3
			elif not self.equips[4]:
				slot = 4
		else:
			slot = equip_dict[equipament.location]
	if self.equips[slot]:
		self.unequip(self.equips[slot], slot)
	self.equips[slot] = equipament
	equipament.equipped = id
	print("Agora "+str(slot)+" tem um "+self.equips[slot].get_name())
	for effect in self.equips[slot].get_effects():
		self.stats[effect.get_id()] += effect.get_value()

func get_equip(location: String):
	if location == "ACCESSORY":
		if self.equips[3]:
			return self.equips[3]
		if self.equips[4]:
			return self.equips[4]
		return null
	var slot = equip_dict[location]
	return self.equips[slot]

func get_resistance():
	return self.resist

func get_resist(type):
	return self.resist[type]

func get_hate():
	return self.hate

func get_job():
	return self.job

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
	self.sprite, self.animations, new_stats, self.position, self.nome, self.skills, self.equips, self.resist)