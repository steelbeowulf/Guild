extends Node

var NODES = {}
var events = {}

func register_node(name, node):
	NODES[name] = node

### Events
func get_event_status(id):
	return events[id]

func set_event_status(id, status):
	events[id] = status

### Dialogue
var caller = null

func play_dialogues(name, portrait, dialogues, callback):
	var node = NODES["Dialogue"]
	node.set_talker(name, portrait)
	for dial in dialogues:
		node.push_dialogue(dial.message)
	caller = callback
	node.start_dialogue()

func play_dialogue(dialogue, callback):
	var node = NODES["Dialogue"]
	node.set_talker(dialogue.name, dialogue.portrait)
	for dial in dialogue.message:
		node.push_dialogue(dial)
	caller = callback
	node.start_dialogue()

func dialogue_ended():
	caller._on_Dialogue_Ended()