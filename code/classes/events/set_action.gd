extends Event
class_name SetAction

var entity: Entity
var action_type: String
var action_arg: int
var action_targets: Array
var force: bool
var turns: int


func _init(
	entity_arg: Entity,
	action_type: String,
	action_arg: int,
	action_targets: Array,
	turns_arg: int,
	force_arg: bool
):
	self.entity = entity_arg
	self.action_type = action_type
	self.action_arg = action_arg
	self.action_targets = action_targets
	self.force = force_arg
	self.turns = turns_arg
	self.type = "SET_ACTION"


func is_forced() -> bool:
	return self.force


func get_entity() -> Entity:
	return self.entity
