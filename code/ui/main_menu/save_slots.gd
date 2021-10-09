extends VBoxContainer

signal slot_chosen


# Called when the node enters the scene tree for the first time.
func _ready():
	load_saves(LOADER.load_save_info())


func remove_focus():
	for c in get_children():
		c.set_focus_mode(0)
		c.disabled = true


func enable_focus(saving):
	for c in get_children():
		if c.get_node("Area").text != "UNUSED" or saving == true:
			c.set_focus_mode(2)
			c.disabled = false
	$Slot0.grab_focus()


func format_gold(money):
	return str(money) + "G"


func format_playtime(T):
	var hours = floor(T / 3600)
	var minutes = floor(T / 60) - hours * 60
	var seconds = int(T) % 60
	return str(hours) + "h" + str(minutes) + "m" + str(seconds) + "s"


func load_saves(saves):
	var tmp = 0
	for slot in get_children():
		if saves[tmp].has("area"):
			slot.get_node("Area").set_text(saves[tmp]["area"]["NAME"])
			slot.get_node("Playtime").set_text(format_playtime(saves[tmp]["playtime"]))
			slot.get_node("Gold").set_text(format_gold(saves[tmp]["gold"]))
			# TODO: Set screenshot
			#slot.get_node("Area").set_text(saves[tmp]["area"]
		tmp += 1
