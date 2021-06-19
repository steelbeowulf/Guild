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
				if stat == "skills":
					continue
				var stat_value = player.get_stats(stat)
				var stat_up = leveled_up[1][stat]
				level_up_text += (stat + ": " + str(stat_value) +" + "+ str(stat_up) +"\n")
			
			if len(leveled_up[1]["skills"]) > 0:
				level_up_text += "New skill(s): \n"
				for skill in leveled_up[1]["skills"]:
					level_up_text += skill.get_name() + "\n"
			$LevelUpLog.show()
			$LevelUpLog.display_text(level_up_text)
	BATTLE_MANAGER.leveled_up = []

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if $LevelUpLog.next():
			AUDIO.play_bgm('MAP_THEME', false)
			get_tree().change_scene("Root.tscn")
