extends HBoxContainer

signal finish_anim

const HP_CRITICAL = Color(1, 0, 0)
const HP_MID = Color(0.75, 0.75, 0)
const HP_FULL = Color(0.33, 0.85, 0.12)

var max_hp = 0
var max_mp = 0
var hp = 0
var mp = 0


func _ready():
	$HP/Fill.set_scale(Vector2(1, 1))
	$MP/Fill.set_scale(Vector2(1, 1))


func set_name(name: String):
	self.show()
	$Name.set_text(name)


func set_level(level: int):
	$Level.set_text(str(level))


func set_initial_hp(hp_arg: int, max_hp_arg: int):
	self.max_hp = max_hp_arg
	self.hp = hp_arg
	$HPText.set_text(str(hp) + "/" + str(max_hp))
	$HP/Fill.set_scale(Vector2(hp / max_hp, 1))


func set_initial_mp(mp_arg: int, max_mp_arg: int):
	self.max_mp = max_mp_arg
	self.mp = mp_arg
	$MPText.set_text(str(mp) + "/" + str(max_mp))
	$MP/Fill.set_scale(Vector2(mp / max_mp, 1))


func set_hp(hp_arg: int):
	if hp_arg < 0:
		hp = 0
	if hp / max_hp <= 0.25:
		$HP/Fill.color = HP_CRITICAL
	elif hp / max_hp <= 0.5:
		$HP/Fill.color = HP_MID
	else:
		$HP/Fill.color = HP_FULL
	$HPText.set_text(str(hp) + "/" + str(max_hp))
	var scale = $HP/Fill.get_scale()
	$Tween.interpolate_property(
		$HP/Fill, "rect_scale", scale, Vector2(hp / max_hp, 1), 1, Tween.TRANS_CIRC, Tween.EASE_OUT
	)
	$Tween.start()


func set_mp(mp_arg: int):
	if mp_arg < 0:
		mp = 0
	$MPText.set_text(str(mp) + "/" + str(max_mp))
	var scale = $MP/Fill.get_scale()
	$Tween.interpolate_property(
		$MP/Fill, "rect_scale", scale, Vector2(mp / max_mp, 1), 1, Tween.TRANS_CIRC, Tween.EASE_OUT
	)
	$Tween.start()


func play(name: String, options = []):
	if name == "UpdateHP":
		self.hp = hp - options
		self.set_hp(hp)
	elif name == "UpdateMP":
		self.mp = mp - options
		self.set_mp(mp)
	else:
		print("[PLAYER_INFO] Updating something weird: ", options)


func _on_Tween_tween_completed(object: Node, _key: String):
	var anim_name = "Update" + object.get_parent().get_name()
	emit_signal("finish_anim", anim_name)
