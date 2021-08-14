extends Node
class_name ActionResult

var type : String

func get_type() -> String:
	return type

func format() -> String:
	return "{type: "+self.type+"}"