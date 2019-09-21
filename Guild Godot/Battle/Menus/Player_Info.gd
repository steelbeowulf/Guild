extends HBoxContainer

const HP_CRITICAL = Color(0.75, 0.75, 0)
const HP_MID = Color(1,0,0)
const HP_FULL = Color(0.33, 0.85, 0.12)

func _ready():
	$HP/Fill.set_scale(Vector2(1,1))
	$MP/Fill.set_scale(Vector2(1,1))

func set_name(name):
	$Name.set_text(name)

func set_level(level):
	$Level.set_text(str(level))

func set_hp(hp, maxHp):
	if hp/maxHp <= 0.25:
		$HP/Fill.color = HP_CRITICAL
	elif hp/maxHp <= 0.5:
		$HP/Fill.color = HP_MID
	else:
		$HP/Fill.color = HP_FULL
	$HPText.set_text(str(hp)+"/"+str(maxHp))
	var scale = $HP/Fill.get_scale()
	$Tween.interpolate_property($HP/Fill, "rect_scale",
        scale, Vector2(hp/maxHp, 1), 1,
        Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func set_mp(mp, maxMp):
	$MPText.set_text(str(mp)+"/"+str(maxMp))
	var scale = $MP/Fill.get_scale()
	$Tween.interpolate_property($MP/Fill, "rect_scale",
        scale, Vector2(mp/maxMp, 1), 1,
        Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()

func _update(hp, maxhp, mp, maxmp):
	self.set_hp(hp, maxhp)
	self.set_mp(mp, maxmp)

func _on_Tween_tween_started(object, key):
	print("fazendo tween no "+str(object)+" usando chave "+str(key))


func _on_Tween_tween_completed(object, key):
	print("completei tween no "+str(object)+" usando chave "+str(key))
