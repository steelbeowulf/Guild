extends "Event.gd"

var name: String
var portrait: String
var messages: Array

func _init(message_arg: Array, name_arg: String = "", portrait_arg: String = ""):
	self.name = name_arg
	self.portrait = portrait_arg
	self.messages = message_arg
	self.type = "DIALOGUE"

func set_portrait(portrait_arg):
	self.portrait = portrait_arg

func set_name(name_arg):
	self.name = name_arg
