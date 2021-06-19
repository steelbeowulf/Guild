extends "Event.gd"

var enemies : Array
var bgm : String
var background : String
var events : Dictionary

func _init(enemies_arg: Array, background_arg: String, bgm_arg: String, events_arg = []):
	self.enemies = enemies_arg
	self.background = background_arg
	self.bgm = bgm_arg
	self.type = "BATTLE"
	self.events = _create_event_dict(events_arg)
	print("[BATTLE EVENT PARSE] "+str(self.events))

func get_events():
	return self.events

func get_event(key: String):
	if events.has(key):
		return events[key]

func get_enemies():
	return self.enemies

func get_background():
	return self.background

func get_bgm():
	return self.bgm

func _create_event_dict(events: Array) -> Dictionary:
	var event_dict = {}
	for e in events:
		event_dict[e.get_condition()] = e
	return event_dict