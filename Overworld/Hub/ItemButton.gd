extends Button

const WHITE = Color(1.0, 1.0, 1.0)
const GRAY = Color(0.4, 0.4, 0.4)


func _ready():
	$Name.set("custom_colors/font_color", WHITE)
	$Cost.set("custom_colors/font_color", WHITE)

func disable():
	self.disabled = true
	$Name.set("custom_colors/font_color", GRAY)
	$Cost.set("custom_colors/font_color", GRAY)

func set_name(name: String):
	$Name.set_text(name)

func set_cost(cost: int):
	$Cost.set_text(str(cost)+"G")