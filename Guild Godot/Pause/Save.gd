extends Control

onready var state = 0
onready var chosen_slot = -1

signal slot_chosen

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_focus()
	var tmp = 0
	for c in get_node("Panel/All/Left/Save Slots").get_children():
		c.connect("button_down", self, "_on_Slot_chosen", [tmp])
		tmp += 1

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		state = 0
		remove_focus()

func format_gold(money):
	return str(money)+"G"

func format_playtime(T):
	var hours = floor(T / 3600);
	var minutes = floor(T / 60) - hours*60;
	var seconds = (int(T) % 60);
	return str(hours)+"h"+str(minutes)+"m"+str(seconds)+"s" 


func load_saves(saves):
	var slots = get_node("Panel/All/Left/Save Slots")
	var tmp = 0
	for slot in slots.get_children():
		if saves[tmp].has("area"):
			slot.get_node("Area").set_text(saves[tmp]["area"]["NAME"])
			slot.get_node("Playtime").set_text(format_playtime(saves[tmp]["playtime"]))
			slot.get_node("Gold").set_text(format_gold(saves[tmp]["gold"]))
			# Set screenshot
			#slot.get_node("Area").set_text(saves[tmp]["area"]
		tmp += 1

func _on_Slot_chosen(binds):
	chosen_slot = binds
	if state == 1:
		$SaveDialog.popup()
	elif state == 2:
		$LoadDialog.popup()

func _on_Save_pressed():
	state = 1
	enable_focus()


func _on_Load_pressed():
	state = 2
	enable_focus()


func _on_Quit_pressed():
	$QuitDialog.popup()


func _on_QuitDialog_confirmed():
	get_tree().quit()

func enable_focus():
	for c in get_node("Panel/All/Left/Save Slots").get_children():
		c.set_focus_mode(2)
		c.disabled = false
	get_node("Panel/All/Left/Save Slots/Slot0").grab_focus()

func remove_focus():
	for c in get_node("Panel/All/Left/Save Slots").get_children():
		c.set_focus_mode(0)
		c.disabled = true
	get_node("Panel/All/Right/Options_Panel/Save").grab_focus()
	get_node("Panel/All/Right/Options_Panel/Save").pressed = false
	get_node("Panel/All/Right/Options_Panel/Load").pressed = false


func _on_SaveDialog_confirmed():
	

	GLOBAL.save(chosen_slot)
	GLOBAL.save_inventory(chosen_slot)
	load_saves(LOADER.load_save_info())
	#Input.action_press("ui_cancel")


func _on_LoadDialog_confirmed():
	pass

	# do actual loading here
