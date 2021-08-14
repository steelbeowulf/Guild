extends "Event.gd"

var group: String
var entities: Array

func _init(type_arg: String, entities_ids: Array):
	self.group = type_arg
	self.entities = []
	if type_arg == "ALLIES":
		for id in entities_ids:
			self.entities.push_back(GLOBAL.get_reserve_player(id))
	else:
		for id in entities_ids:
			self.entities.push_back(LOCAL.get_enemy(id))
	self.type = "REINFORCEMENTS"

func get_group() -> String:
	return self.group

func get_entities() -> Array:
	return self.entities