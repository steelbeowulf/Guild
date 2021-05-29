extends Node2D

func _ready():
	$AnimationManager.initialize(GLOBAL.PLAYERS, [])
	
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", TEXT.get_font())
	
	$AnimationManager/Log.display_text("Enemies defeated!")
	for i in range(len(GLOBAL.PLAYERS)):
		var player = GLOBAL.PLAYERS[i]
		var leveled_up = BATTLE_MANAGER.leveled_up[i]
		if leveled_up[0] > 0:
			var current = player.get_level()
			var prev = current - leveled_up[0]
			var level_up_text = player.get_name() + " has leveled up! (" + str(prev) + " -> " + str(current) + ")\n"
			for stat in leveled_up[1].keys():
				var stat_value = player.get_stats(stat)
				var stat_up = leveled_up[1][stat]
				level_up_text += (stat + ": " + str(stat_value) +" + "+ str(stat_up) +"\n")
			
			$LevelUpLog.show()
			$LevelUpLog.display_text(level_up_text)
	BATTLE_MANAGER.leveled_up = []

func _process(delta):
	if $Timer.time_left == 0:
		if Input.is_key_pressed(KEY_SPACE):
			AUDIO.play_bgm('MAP_THEME', false)
			get_tree().change_scene("Root.tscn")



func _on_Timer_timeout():
	pass # Replace with function body.
