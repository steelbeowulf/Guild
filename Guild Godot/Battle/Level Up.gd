extends Node2D
var Players
var Players_img = []

func _ready():
	$Timer.start()
	Players = BATTLE_INIT.Play
	
	for c in get_node("Menu").get_children():
		c.focus_previous = NodePath("Menu/Attack")
	
	var lane
	for i in range(Players.size()):
		# Graphics stuff
		lane = Players[i].get_pos()
		var node = get_node("Players/P"+str(i))
		Players_img.append(node)
		node.parent = self
		node.change_lane(lane)
		node.set_sprite(Players[i].sprite)
		node.show()
		Players[i].graphics = node
	$Log.display_text("Enemies defeated!")
	for p in BATTLE_INIT.Play:
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
		if p.xp >= up:
			$Log.display_text(p.nome + " subiu de nivel")
			$LevelUpLog.show()
			$LevelUpLog.display_text("HP:" + str(max_hp) +"+"+ str(BATTLE_INIT.lvup_max_hp) +"\n"+ "MP:" +str(max_mp) +"+"+ str(BATTLE_INIT.lvup_max_mp) + "\n" + "ATK:" +str(atk) +"+"+ str(BATTLE_INIT.lvup_atk) + "\n" +"ATKM:" +str(atkm) +"+"+ str(BATTLE_INIT.lvup_atkm)+ "\n" + "DEF:" +str(def) +"+"+ str(BATTLE_INIT.lvup_def)+ "\n" + "DEFM:" +str(defm) +"+"+ str(BATTLE_INIT.lvup_defm)+ "\n" + "ACC:" +str(acc) +"+"+ str(BATTLE_INIT.lvup_acc)+ "\n" + "LCK:" +str(lck) +"+"+ str(BATTLE_INIT.lvup_lck)+ "\n" + "AGI:" +str(agi) +"+"+ str(BATTLE_INIT.lvup_agi))
			#$LevelUpLog.display_text("MP:" +str(max_mp) +"+"+ str(BATTLE_INIT.lvup_max_mp))
			#$LevelUpLog.display_text("ATK:" +str(atk) +"+"+ str(BATTLE_INIT.lvup_atk))
			#$LevelUpLog.display_text("ATKM:" +str(atkm) +"+"+ str(BATTLE_INIT.lvup_atkm))
			#$LevelUpLog.display_text("DEF:" +str(def) +"+"+ str(BATTLE_INIT.lvup_def))
			#$LevelUpLog.display_text("DEFM:" +str(defm) +"+"+ str(BATTLE_INIT.lvup_defm))
			#$LevelUpLog.display_text("ACC:" +str(acc) +"+"+ str(BATTLE_INIT.lvup_acc))
			#$LevelUpLog.display_text("LCK:" +str(lck) +"+"+ str(BATTLE_INIT.lvup_lck))
			#$LevelUpLog.display_text("AGI:" +str(agi) +"+"+ str(BATTLE_INIT.lvup_agi))
	
func _process(delta):
	if $Timer.time_left == 0:
		if Input.is_key_pressed(KEY_SPACE):
			get_tree().change_scene("res://Overworld/Map"+str(GLOBAL.MAP)+".tscn")

