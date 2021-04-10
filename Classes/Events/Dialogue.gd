extends "Event.gd"

var name : String
var portrait : String
var message: String

func _init(name_arg: String, portrait_arg: String, message_arg: String):
	self.name = name_arg
	self.portrat = portrait_arg
	self.message = message_arg