extends "Entity.gd"

var dialogues

func _init(id, name, img, anim, dialogue):
	self.id = id
	self.nome = name
	self.sprite = img
	self.animations = anim
	self.dialogues = dialogue
	self.tipo = "NPC"

func save_data():
	var dict = {}
	dict["ID"] = id
	dict["IMG"] = get_sprite()
	dict["ANIM"] = get_animation()
	return dict

func get_sprite():
	return self.sprite

func get_animation():
	return self.animations

func get_dialogues():
	return dialogues

func _duplicate():
	var new_stats = [] + self.stats
	return self.get_script().new(self.id, self.level, self.xp, 
	self.sprite, self.animations, new_stats, self.position, self.nome, self.skills, self.resist)