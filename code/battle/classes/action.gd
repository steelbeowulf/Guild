extends Node
class_name Action
"""
	Represents an Action that might be taken by an Entity during Battle
	Action types: ATTACK, LANE, SKILL, ITEM, RUN
"""

var type: String
var action: int
var targets: PoolIntArray


func _init(type_arg: String, action_arg: int, targets_arg: PoolIntArray):
	self.type = type_arg
	self.action = action_arg
	self.targets = targets_arg


func get_type() -> String:
	return type


func get_action() -> int:
	return action


func get_targets() -> PoolIntArray:
	return targets
