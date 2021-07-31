extends "Event.gd"

var enemies : Array
var enemy_ids : Array
var bgm : String
var background : String
var events : Dictionary
var original_events : Array

func _init(enemies_arg: Array, background_arg: String, bgm_arg: String, events_arg = []):
	self.enemy_ids = enemies_arg
	self.enemies = BATTLE_MANAGER._load_enemies(enemies_arg)
	self.background = background_arg
	self.bgm = bgm_arg
	self.type = "BATTLE"
	self.original_events = events_arg
	self.events = _create_event_dict(events_arg)
	self.played = false
	self.recurrence = "ONCE"
	print("[BATTLE EVENT PARSE] "+str(self.events))


func add_events(events_arg: Array) -> void:
	self.original_events = events_arg
	self.events = _create_event_dict(events_arg)


func find_entity_by_name(name_arg: String) -> Entity:
	for e in self.enemies:
		if e.get_name() == name_arg:
			return e
	for p in GLOBAL.PLAYERS:
		if p.get_name() == name_arg:
			return p
	return null


func get_all_events():
	return self.events


func get_events(key: String):
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
		var k = e.get_condition()
		if event_dict.has(k):
			event_dict[k].append(e)
		else:
			event_dict[k] = [e]
	return event_dict

func _duplicate():
	var new_events = self.original_events.duplicate(true)
	return self.get_script().new(self.enemy_ids, self.background, self.bgm, new_events)
