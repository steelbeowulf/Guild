extends Event
class_name Dialogue

var name: String
var portrait: Dictionary
var messages: Array

func _init(message_arg: Array, name_arg: String = "", portrait_arg: Dictionary = {}):
	self.name = name_arg
	self.portrait = portrait_arg
	self.messages = message_arg
	self.type = "DIALOGUE"
	self.played = false
	self.recurrence = "ONCE"

func set_portrait(portrait_arg):
	self.portrait = portrait_arg

func set_name(name_arg):
	self.name = name_arg
