extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_name(name):
	$Name.set_text(name)

func set_level(level):
	$Level.set_text(str(level))

func set_hp(hp, maxHp):
	$HPText.set_text(str(hp)+"/"+str(maxHp))
	$HP/Fill.set_scale(Vector2(hp/maxHp, 1))

func set_mp(mp, maxMp):
	$MPText.set_text(str(mp)+"/"+str(maxMp))
	$MP/Fill.set_scale(Vector2(mp/maxMp, 1))

func _update(hp, maxhp, mp, maxmp):
	self.set_hp(hp, maxhp)
	self.set_mp(mp, maxmp)