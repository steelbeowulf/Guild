extends Button
onready var id = -1


func update_info(player):
	self.show()
	id = player.id
	$Name.set_text(player.get_name())
	$Job.set_text(player.get_job())
	$Level.set_text(str(player.level))
	var tmp = str(player.get_health()) + "/" + str(player.get_max_health())
	$HP.set_text(tmp)
	tmp = str(player.get_mp()) + "/" + str(player.get_max_mp())
	$MP.set_text(tmp)
	tmp = str(player.xp) + "/" + str(player.get_exp_to_level_up())
	$EXP.set_text(tmp)
	set_lane(player.position)
	$Sprite.set_texture(load(player.portrait))


func set_lane(lane):
	for l in $Lanes.get_children():
		l.pressed = false
	$Lanes.get_child(lane).pressed = true
	var player = GLOBAL.get_player(id)
	player.position = lane


func _on_Back_pressed():
	set_lane(0)


func _on_Mid_pressed():
	set_lane(1)


func _on_Front_pressed():
	set_lane(2)
