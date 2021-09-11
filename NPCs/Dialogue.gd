extends Control

var dialogues = []
var dialogue = ""
var max_cols = 70
var max_lines = 3

func _ready():
	$Text.add_font_override("font", TEXT.get_font())
	EVENTS.register_node("Dialogue", self)


func _process(delta):
	if $AnimationPlayer.is_playing() and Input.is_action_just_pressed("ui_accept"):
		$End.hide()
		$AnimationPlayer.stop()
		start_dialogue()
	elif Input.is_action_pressed("ui_accept"):
		$Tween.set_speed_scale(5.0)
	else:
		$Tween.set_speed_scale(1.0)


func start_dialogue():
	if len(dialogues) > 0 or dialogue != "":
		self.show()
		$Text.add_font_override("font", TEXT.get_font())
		set_dialogue(dialogues.pop_front())
	else:
		self.hide()
		dialogue = ""
		EVENTS.dialogue_ended()


func push_dialogue(text):
	var num_lines = max(len(text)/max_cols + 1, 1)
	var new_text = ""
	var current_line = 0
	var words = text.split(" ")
	for i in range(num_lines):
		var line_size = 0
		while words and (line_size + len(words[0])) < max_cols:
			new_text += words[0]
			line_size += len(words[0]) + 1
			words.remove(0)
			new_text += " "
		new_text += "\n"
		current_line += 1
		if current_line == num_lines or current_line == max_lines:
			num_lines -= max_lines
			current_line = 0
			dialogues.append(new_text)
			new_text = ""


func set_talker(name, portrait):
	$Id.set_text(name)
	$Sprite.set_texture(load(portrait.sprite))
	$Sprite.set_scale(Vector2(portrait.scale[0], portrait.scale[1]))


func set_dialogue(text):
	dialogue = text
	if dialogue:
		var speed = max(len(dialogue)/TEXT.get_speed(), 1.0)
		$Tween.follow_method(self, "set_text", 0, self, "get_length", speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
		$Tween.set_speed_scale(1.0)
		$Tween.start()
	else:
		EVENTS.dialogue_count -= 1
		EVENTS.dialogue_ended()
		if EVENTS.dialogue_count <= 0 and not EVENTS.waiting_for_choice:
			EVENTS.dialogue_ended()
			self.hide()
			dialogue = ""

func reset():
	self.hide()
	dialogue = ""


func set_text(value):
	AUDIO.play_se("MOVE_MENU")
	$Text.set_text(dialogue.substr(0,floor(value)))


func get_length():
	return len(dialogue)


func _on_Tween_tween_completed(object, key):
	$End.show()
	$AnimationPlayer.play("Float")
