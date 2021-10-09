class_name Event

var condition
var arguments: Array
var recurrence: String = "ONCE"
var played = false
var type: String


func get_type():
	return self.type


func get_condition():
	return self.condition


func add_condition(condition_arg):
	if typeof(condition_arg) == TYPE_ARRAY:
		self.condition = condition_arg[0]
		self.arguments = condition_arg[1]
	else:
		self.condition = condition_arg


func add_recurrence(recurrence_arg: String):
	self.recurrence = recurrence_arg


func set_played(played_arg: bool):
	self.played = played_arg


func has_played() -> bool:
	return self.played


func should_repeat() -> bool:
	return self.recurrence != "ONCE"


func get_arguments():
	return self.arguments


func get_argument(num: int):
	if num < len(self.arguments):
		return self.arguments[num]
	return null
