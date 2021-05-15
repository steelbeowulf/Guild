extends "res://Battle/Apply.gd"

onready var location = "OUTSIDE"
var targets = []
var item = null
var player = null
var target = null
var type = "ONE"

func enter(item_arg, player_arg):
	location = "TARGETS"
	get_node("Panel/All/Left/Chars/Char0").grab_focus()
	for i in range(len(GLOBAL.PLAYERS)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.update_info(GLOBAL.PLAYERS[i])
		node.connect("pressed", self, "_on_Char_pressed", [i])
		node.connect("focus_entered", self, "_on_Focus_Entered")
	item = item_arg
	player = player_arg
	if item.target == "ALL":
		$Panel/All/Right/Options_Panel/Panel/Question.set_text("Usar "+item.nome+" \nem todos os personagens?")
		targets = GLOBAL.PLAYERS
		type = "ALL"

func give_focus():
	for c in $Panel/All/Left/Chars.get_children():
		c.set_focus_mode(2)
	get_node("Panel/All/Left/Chars/Char0").grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_cancel") and location == "TARGETS":
		get_parent().get_parent().get_parent().back_to_skills(player.id)
		queue_free()
	#if Input.is_action_just_pressed("ui_accept") and type=="ALL":
	#	use_item()

func use_item():
	var mp = player.get_mp()
	player.set_stats(2, mp - item.quantity)
	for target in targets:
		for effect in item.get_effects():
			apply_effect(player, effect, target, null)
		for status in item.get_status():
			apply_status(status, target, player)
	location = "OUTSIDE"
	AUDIO.play_se("SPELL", -12)
	get_parent().get_parent().get_parent().back_to_skills(player.id)
	queue_free()

func _on_Char_pressed(id):
	AUDIO.play_se("ENTER_MENU")
	print("[ITEM USE] pressei "+str(id))
	print(GLOBAL.PLAYERS[id].status)
	if type != "ALL":
		targets.append(GLOBAL.PLAYERS[id])
	use_item()

func _on_Focus_Entered():
	AUDIO.play_se("MOVE_MENU")