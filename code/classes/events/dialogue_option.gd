class_name DialogueOption
extends Event

var option: String
var events: Array


func _init(option_arg: String, events_arg: Array):
	self.option = option_arg
	self.events = events_arg
	self.type = "DIALOGUE_OPTION"


func get_option():
	return option


func get_results():
	return events
