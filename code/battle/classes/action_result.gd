extends Node
class_name ActionResult
"""
	Represents the result of an Action that might be taken by an Entity during Battle
	Currently unused
"""

var type : String

func get_type() -> String:
	return type

func format() -> String:
	return "{type: "+self.type+"}"