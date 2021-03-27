extends "Entity.gd"

var dialogues
var portrait
var itens
var equips

func _init(id, name, img, anim, dialogue, portrait, itens, equips):
	self.id = id
	self.nome = name
	self.sprite = img
	self.animations = anim
	self.dialogues = dialogue
	self.portrait = portrait
	self.itens = itens
	self.equips = equips
	self.tipo = "SHOP"

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

func get_itens():
	return itens

func get_equips():
	return equips