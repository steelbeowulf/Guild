extends Button

var id = -1

func init(player_id: int):
	var player = GLOBAL.players[player_id]
	id = player_id
	$Sprite.set_texture(load(player.get_portrait()))
	$Sprite.use_parent_material = true
	self.show()

func make_active():
	$Sprite.use_parent_material = true
	self.disabled = false

func make_inactive():
	$Sprite.use_parent_material = false
	self.disabled = true
