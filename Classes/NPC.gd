extends "Entity.gd"

var dialogues
var portrait

func _init(id, name, img, anim, dialogue, portrait):
	self.id = id
	self.nome = name
	self.sprite = img
	self.animations = anim
	self.dialogues = dialogue
	self.portrait = portrait
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

func get_portrait():
	return portrait
