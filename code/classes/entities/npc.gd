class_name NPC
extends Entity

var events
var portrait


func _init(
	id: int, name: str, img: str, animations: Dictionary, events: Dictionary, portrait: Dictionary
):
	self.id = id
	self.name = name
	self.sprite = img
	self.animations = animations
	self.events = events
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
