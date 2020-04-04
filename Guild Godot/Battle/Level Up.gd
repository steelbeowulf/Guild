extends Node2D
var Players
var Players_img = []

func _ready():
	Players = GLOBAL.ALL_PLAYERS
	$AnimationManager.initialize(Players, [])
		
	$AnimationManager/Log.display_text("Enemies defeated!")
	for p in Players:
		var max_hp = p.get_max_health()
		var max_mp = p.get_max_mp()
		var agi = p.get_agi()
		var atk = p.get_atk()
		var atkm = p.get_atkm()
		var def = p.get_def()
		var defm = p.get_defm()
		var acc = p.get_acc()
		var lck = p.get_lck()
		var up = ((18/10)^p.level)*5
		if BATTLE_MANAGER.leveled_up[p.id]:
			$LevelUpLog.show()
			$LevelUpLog.display_text(p.nome + " subiu de nivel!\n"+ "HP:" + str(max_hp) +"+"+ str(BATTLE_MANAGER.lvup_max_hp) +"\n"+ "MP:" +str(max_mp) +"+"+ str(BATTLE_MANAGER.lvup_max_mp) + "\n" + "ATK:" +str(atk) +"+"+ str(BATTLE_MANAGER.lvup_atk) + "\n" +"ATKM:" +str(atkm) +"+"+ str(BATTLE_MANAGER.lvup_atkm)+ "\n" + "DEF:" +str(def) +"+"+ str(BATTLE_MANAGER.lvup_def)+ "\n" + "DEFM:" +str(defm) +"+"+ str(BATTLE_MANAGER.lvup_defm)+ "\n" + "ACC:" +str(acc) +"+"+ str(BATTLE_MANAGER.lvup_acc)+ "\n" + "LCK:" +str(lck) +"+"+ str(BATTLE_MANAGER.lvup_lck)+ "\n" + "AGI:" +str(agi) +"+"+ str(BATTLE_MANAGER.lvup_agi))

func _process(delta):
	if $Timer.time_left == 0:
		if Input.is_key_pressed(KEY_SPACE):
			AUDIO.play_bgm('MAP_THEME', false)
			get_tree().change_scene("Root.tscn")



func _on_Timer_timeout():
	pass # Replace with function body.
