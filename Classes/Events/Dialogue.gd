extends "Event.gd"

var name: String
var portrait: String
var message: String

func _init(message_arg: String, name_arg: String = "", portrait_arg: String = ""):
	self.name = name_arg
	self.portrait = portrait_arg
	self.message = message_arg

func set_portrait(portrait_arg):
	self.portrait = portrait_arg

func set_name(name_arg):
	self.name = name_arg
