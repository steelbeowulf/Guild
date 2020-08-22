extends HBoxContainer

const HP_CRITICAL = Color(1, 0, 0)
const HP_MID = Color(0.75,0.75,0)
const HP_FULL = Color(0.33, 0.85, 0.12)
var maxHp = 0
var maxMp = 0
var Hp = 0
var Mp = 0

func _ready():
	$HP/Fill.set_scale(Vector2(1,1))
	$MP/Fill.set_scale(Vector2(1,1))

func set_name(name):
	self.show()
	$Name.set_text(name)

func set_level(level):
	$Level.set_text(str(level))

func set_initial_hp(hp, max_hp):
	self.maxHp = max_hp
	self.Hp = hp
	$HPText.set_text(str(Hp)+"/"+str(maxHp))
	$HP/Fill.set_scale(Vector2(hp/max_hp,1))
	
func set_initial_mp(mp, max_mp):
	self.maxMp = max_mp
	self.Mp = mp
	$MPText.set_text(str(Mp)+"/"+str(maxMp))
	$MP/Fill.set_scale(Vector2(mp/max_mp,1))

func set_hp(hp):
	if hp < 0:
		Hp = 0
		hp = 0
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

func set_mp(mp):
	if mp < 0:
		Mp = 0
		mp = 0
	$MPText.set_text(str(mp)+"/"+str(maxMp))
	var scale = $MP/Fill.get_scale()
	$Tween.interpolate_property($MP/Fill, "rect_scale",
        scale, Vector2(mp/maxMp, 1), 1,
        Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()


func play(name, options=[]):
	if name == 'UpdateHP':
		self.Hp = Hp - options
		self.set_hp(Hp)
	elif name == 'UpdateMP':
		self.Mp = Mp - options
		self.set_mp(Mp)
	else:
		print("UPDATE DUNNO WHAT")
		print(options)

func _on_Tween_tween_started(object, key):
	pass



func _on_Tween_tween_completed(object, key):
	pass

