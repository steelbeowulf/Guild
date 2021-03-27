extends Control
var stats = STATS.DSTAT.values()

const WHITE = Color(1.0, 1.0, 1.0)
const GREEN = Color(0.0, 1.0, 0.0)
const RED = Color(1.0, 0.0, 0.0)

func init(current_equip, new_equip):
	for stat_id in stats:
		var diff = new_equip.get_effect(stat_id)
		if current_equip != null:
			diff = current_equip.get_effect(stat_id) - new_equip.get_effect(stat_id)
		set_diff(stat_id, diff)

func set_diff(stat: int, diff: int):
	var stat_name = STATS.ISTAT[stat]
	var node = $"HBoxContainer/Attributes-Left".get_node(stat_name)
	if not node:
		node = $"HBoxContainer/Attributes-Right".get_node(stat_name)
	var symbol = "(=)"
	var color = WHITE
	var tex_dif = ""
	if diff > 0:
		tex_dif = str(diff)
		symbol = "(+)"
		color = GREEN
	elif diff < 0:
		tex_dif = str(abs(diff))
		symbol = "(-)"
		color = RED
	node.set_text(stat_name+" "+symbol+" "+tex_dif)
	node.set("custom_colors/font_color", color)