class_name Job

# Class
var id
var name
var proficiencies
var skills

# Instance
var level
var experience

func _init(id_arg: int, name_arg: String, prof_arg: Dictionary, sk_arg: Dictionary):
	self.id = id_arg
	self.name = name_arg
	self.proficiencies = prof_arg
	self.skills = sk_arg
	
func get_name():
	return name

func get_proficiencies():
	return proficiencies

func get_skills():
	return skills

func get_level():
	return level

func set_level(level_arg: int):
	self.level = level_arg

func clone():
	return self.get_script().new(self.id, self.name, self.proficiencies, self.skills)