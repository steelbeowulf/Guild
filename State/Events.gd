extends Node

var NODES = {}


func register_node(name, node):
	NODES[name] = node

### Events
func get_event_status(id):
	return events[id]

func set_event_status(id, status):
	events[id] = status

### Dialogue
var caller = null
var events = []
var npc_name = ""
var npc_portrait = ""

func play_events(events: Array):
	self.events = events.duplicate(true)
	play_event(self.events.pop_front())

func play_event(event: Event):
	print("[EVENTS] Playing event ", event.type)
	if LOCAL.IN_BATTLE:
		get_node("/root/Battle").pause()
		caller = BATTLE_MANAGER
	if event.type == "DIALOGUE":
		var node = NODES["Dialogue"]
		if event.portrait and event.name:
			node.set_talker(event.name, event.portrait)
		else:
			node.set_talker(npc_name, npc_portrait)
		for dial in event.messages:
			node.push_dialogue(dial)
		node.start_dialogue()
	elif event.type == "DIALOGUE_OPTION":
		var node = NODES["DialogueOptions"]
		node.push_option(event)
		for ev in events:
			if ev.type != "DIALOGUE_OPTION":
				break
			events.pop_front()
			node.push_option(ev)
		node.show_options()
	elif event.type == "SHOP":
		GLOBAL.get_root().open_shop(event)
	elif event.type == "BATTLE":
		BATTLE_MANAGER.initiate_event_battle(event)
	elif event.type == "TRANSITION":
		GLOBAL.get_root().change_area(event.get_area(), event.get_map(), event.get_position())

func start_npc_dialogue(name, portrait, events, callback):
	var node = NODES["Dialogue"]
	npc_name = name
	npc_portrait = portrait
	node.set_talker(name, portrait)
	play_events(events)
	caller = callback

func dialogue_ended(force_hide = false):
	print("[EVENTS] Dialogue ended")
	if force_hide:
		NODES["Dialogue"].reset()
	if len(self.events) == 0:
		print("[EVENTS] Callback time")
		caller._on_Dialogue_Ended()
	else:
		play_event(self.events.pop_front())