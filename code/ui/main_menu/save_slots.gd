extends VBoxContainer

signal slot_chosen


# Called when the node enters the scene tree for the first time.
func _ready():
	load_saves(LOADER.load_save_info())


func remove_focus():
	for c in get_children():
		c.set_focus_mode(0)
		c.disabled = true


func enable_focus(saving: bool):
	for c in get_children():
		if c.get_node("Area").text != "UNUSED" or saving == true:
			c.set_focus_mode(2)
			c.disabled = false
	$Slot0.grab_focus()


func format_gold(money: int):
	return str(money) + "G"


func format_playtime(time: int):
	var hours = floor(time / 3600)
	var minutes = floor(time / 60) - hours * 60
	var seconds = int(time) % 60
	return str(hours) + "h" + str(minutes) + "m" + str(seconds) + "s"


func load_saves(saves: Array):
	var i = 0
	for slot in get_children():
		if saves[i].has("area"):
			slot.get_node("Area").set_text(saves[tmp]["area"]["NAME"])
			slot.get_node("Playtime").set_text(format_playtime(saves[tmp]["playtime"]))
			slot.get_node("Gold").set_text(format_gold(saves[tmp]["gold"]))
			# TODO: Set screenshot
		i += 1
