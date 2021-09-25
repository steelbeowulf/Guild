extends Entity
class_name NPC

var events
var portrait

func _init(id, name, img, anim, event, portrait):
	self.id = id
	self.nome = name
	self.sprite = img
	self.animations = anim
	self.events = event
	self.portrait = portrait
	self.tipo = "NPC"

func save_data():
	var dict = {}
	dict["ID"] = id
	dict["IMG"] = get_sprite()
	dict["ANIM"] = get_animation()
	return dict

func get_sprite():
	return self.sprite

func get_animation():
	return self.animations

func get_events():
	return events

func get_portrait():
	return portrait
