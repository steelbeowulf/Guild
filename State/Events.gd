extends Node

var NODES = {}
var flags = {}

var dialogue_count = 0
var waiting_for_choice = false

func load_flags(flags_arg: Dictionary):
	flags = flags_arg

func set_flag(event: Event):
	var key = event.get_key()
	var value = event.get_value()
	flags[key] = value

func get_flag(key: String):
	if flags.has(key):
		return flags[key]
	return null

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
	dialogue_count = 0
	self.events = events.duplicate(true)
	for e in events:
		if e.type == 'DIALOGUE':
			dialogue_count += 1
	return play_event(self.events.pop_front())

func play_event(event: Event) -> bool:
	print("[EVENTS] Playing event ", event.type)
	print("[EVENTS] Has played: "+str(event.has_played()))
	print("[EVENTS] Should repeat: "+str(event.should_repeat()))
	if LOCAL.IN_BATTLE and event.has_played() and not event.should_repeat():
		event_ended()
	event.set_played(true)
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
		waiting_for_choice = true
	elif event.type == "FLAG":
		EVENTS.set_flag(event)
		event_ended()
	elif event.type == "SHOP":
		GLOBAL.get_root().open_shop(event)
	elif event.type == "BATTLE":
		BATTLE_MANAGER.initiate_event_battle(event)
	elif event.type == "TRANSITION":
		GLOBAL.get_root().change_area(event.get_area(), event.get_map(), event.get_position())
	elif event.type == "REINFORCEMENTS":
		if event.group == "ALLIES":
			get_node("/root/Battle").add_players(event.entities)
		else:
			get_node("/root/Battle").add_enemies(event.entities)
	elif event.type == "SET_TARGET":
		event.entity.set_next_target(event.get_target().index, event.get_turns())
		event_ended()
	elif event.type == "SET_ACTION":
		event.entity.set_next_action(
			build_action(event.action_type, event.action_arg, event.action_targets),
			event.turns
		)
		if event.is_forced():
			get_node("/root/Battle").force_next_action(event.entity)
		event_ended()
	return true


func build_action(type_arg: String, action_id: int, args: Array) -> Action:
	var targets = []
	for a in args:
		targets.append(BATTLE_MANAGER.current_battle.find_entity_by_name(a).index)
	return Action.new(type_arg, action_id, targets)


func start_npc_dialogue(name, portrait, events, callback):
	var node = NODES["Dialogue"]
	npc_name = name
	npc_portrait = portrait
	node.set_talker(name, portrait)
	play_events(events)
	caller = callback


func event_ended():
	print("[EVENTS] Event finished! ")
	if len(self.events) > 0:
		play_event(self.events.pop_front())
	else:
		print("[EVENTS] Callback event time")
		caller._on_Dialogue_Ended()


func dialogue_ended(force_hide = false):
	print("[EVENTS] Dialogue ended, force_hide = ", force_hide)
	if force_hide:
		NODES["Dialogue"].reset()
	if len(self.events) > 0:
		play_event(self.events.pop_front())
	else:
		print("[EVENTS] Callback dialogue time")
		caller._on_Dialogue_Ended()