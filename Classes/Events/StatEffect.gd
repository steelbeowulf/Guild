class_name StatEffect

var id : int
var name : String
var value : float
var type : String

func _init(id_arg: int, name_arg: String, value_arg: float, type_arg: String):
	self.id = id_arg
	self.name = name_arg
	self.value = value_arg
	self.type = type_arg

func get_id():
	return id

func get_name():
	return name

func get_type():
	return type

func get_value():
	return value

func format():
	return "{id: "+str(id)+", value: "+str(value)+", type: "+str(type)+", name: "+str(name)+"}"
