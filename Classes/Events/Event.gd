class_name Event

var condition
var argument
var recurrence
var automatic: bool
var type: String

func get_type():
	return self.type

func get_condition():
	return self.condition

func add_condition(condition_arg):
	if typeof(condition_arg) == TYPE_ARRAY:
		self.condition = condition_arg[0]
		self.argument = condition_arg[1]
	else:
		self.condition = condition_arg

func get_argument():
	return self.argument
