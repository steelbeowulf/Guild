extends Event
class_name Flag

var key: String
var value


func _init(key_arg: String, value_arg):
	self.key = key_arg
	self.value = value_arg
	self.type = "FLAG"


func get_key():
	return self.key


func get_value():
	return self.value
