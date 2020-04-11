extends Control

var dialogues = []
var dialogue = ""

func _ready():
	$Text.add_font_override("font", TEXT.get_font())
	GLOBAL.register_node("Dialogue", self)
	#push_dialogue("Oi, meu nome é Papu!")
	#push_dialogue("Tudo bem com você?")
	#push_dialogue("Guild será o melhor jogo de RPG de todos os tempos! \nVou escrever várias coisas até encher a caixa! Hehehehehe")
	#start_dialogue()


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
		GLOBAL.dialogue_ended()


func push_dialogue(text):
	dialogues.append(text)


func set_talker(name, sprite=null):
	$Id.set_text(name)
	#$Sprite.set_texture(sprite)


func set_dialogue(text):
	dialogue = text
	if dialogue:
		var speed = len(dialogue)/TEXT.get_speed()
		$Tween.follow_method(self, "set_text", 0, self, "get_length", speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
		$Tween.set_speed_scale(1.0)
		$Tween.start()
	else:
		self.hide()
		dialogue = ""
		GLOBAL.dialogue_ended()


func set_text(value):
	$Text.set_text(dialogue.substr(0,floor(value)))


func get_length():
	return len(dialogue)


func _on_Tween_tween_completed(object, key):
	$End.show()
	$AnimationPlayer.play("Float")
