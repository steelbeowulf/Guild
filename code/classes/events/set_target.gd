extends Event
class_name SetTarget

var entity: Entity
var target: Entity
var turns: int

func _init(entity_arg: Entity, target_arg: Entity, turns_arg: int):
	self.entity = entity_arg
	self.target = target_arg
	self.turns = turns_arg
	self.type = "SET_TARGET"

func get_entity() -> Entity:
	return self.entity

func get_target() -> Entity:
	return self.target

func get_turns() -> int:
	return self.turns