extends "res://code/battle/apply.gd"

onready var location = "OUTSIDE"
var targets = []
var item = null
var type = "ONE"
var whatdo = "RECOVERY"

func enter(item_arg):
	location = "TARGETS"
	get_node("Panel/All/Left/Chars/Char0").grab_focus()
	for i in range(len(GLOBAL.PLAYERS)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.update_info(GLOBAL.PLAYERS[i])
		node.connect("pressed", self, "_on_Char_pressed", [i])
		node.connect("focus_entered", self, "_on_Focus_Entered")
	item = item_arg
	whatdo = item.type
	if item.target == "ALL":
		$Panel/All/Right/Options_Panel/Panel/Question.set_text("Usar "+item.nome+" \nem todos os personagens?")
		targets = GLOBAL.PLAYERS
		type = "ALL"

func give_focus():
	var i = 0;
	for c in $Panel/All/Left/Chars.get_children():
		c.set_focus_mode(2)
	get_node("Panel/All/Left/Chars/Char0").grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and location == "TARGETS":
		get_parent().get_parent().get_parent().back_to_inventory()
		queue_free()
	#elif Input.is_action_just_pressed("ui_accept") and type=="ALL":
	#	use_item()

func use_item():
	for player in targets:
		for effect in item.get_effects():
			apply_effect(player, effect, player, "Item", true, false)
		for status in item.get_status():
			apply_status(status, player, player)
	location = "OUTSIDE"
	AUDIO.play_se("SPELL", -12)
	item.quantity = item.quantity - 1
	get_parent().get_parent().get_parent().back_to_inventory()
	queue_free()

func _on_Char_pressed(id):
	AUDIO.play_se("ENTER_MENU")
	print("[ITEM USE] pressei "+str(id))
	if whatdo == "RESSURECTION":
		if GLOBAL.PLAYERS[id].status != "KO":
			get_parent().get_parent().get_parent().back_to_inventory()
			queue_free()
	if type != "ALL":
		targets.append(GLOBAL.PLAYERS[id])
	use_item()

func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")