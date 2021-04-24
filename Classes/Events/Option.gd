extends "Event.gd"

var option: String
var events: Array

func _init(option_arg: String, events_arg: Array):
	self.option = option_arg
	self.events = events_arg
	self.type = "DialogueOption"

func get_option():
	return option

func get_results():
	return events