extends "Entity.gd"

var dialogues
var portrait

func _init(id, name, dialogue):
	self.id = id
	self.nome = name
	self.dialogues = dialogue
	self.tipo = "ENCOUNTER"

func save_data():
	var dict = {}
	dict["ID"] = id
	return dict

func get_dialogues():
	return dialogues