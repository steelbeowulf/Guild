extends Node

var player = null
const RANGER_PATH = "res://Demo_data/Ranger.json"
var encounter = null

func start_dialogue(id):
	encounter = GLOBAL.ENCOUNTERS[id].dialogues
	var next = encounter.pop_front()
	GLOBAL.play_dialogue(next, self)

func _on_Dialogue_Ended():
	var next = encounter.pop_front()
	if next:
		GLOBAL.play_dialogue(next, self)
	else: _on_Encounter_Ended()

func _on_Encounter_Ended():
	if len(get_parent().get_node("Enemies").get_children()) > 0:
		GLOBAL.set_event_status("rangers_defeated", true)
		get_parent().get_node("Enemies/Ranger1")._on_Battle_body_entered(player)
	else:
		join_ranger()
		player.stop = []
		get_parent().get_node("Bravo").show()

func join_ranger():
	if len(GLOBAL.PLAYERS) < 4:
		var loader = GLOBAL.get_root().get_parent().get_node("/root/LOADER")
		GLOBAL.PLAYERS.append(loader.parse_players(RANGER_PATH)[0])

func _on_AreaEvent_body_entered(body):
	if body.is_in_group("player") and len(GLOBAL.PLAYERS) < 4: 
		player = body
		player.stop.push_back(0)
		if GLOBAL.get_event_status("rangers_defeated"):
			start_dialogue(1)
		else:
			start_dialogue(0)
	elif len(GLOBAL.PLAYERS) > 3:
		player.stop = []
		get_parent().get_node("Bravo").show()
