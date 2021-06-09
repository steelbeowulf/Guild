extends Node2D

# with this var and these 2 functions I control the quantify the strength 
var strength_value = 0

func _ready():
	get_tree().paused = true

func _process(_delta):
	#$Bar_color.animation = "Idle" + "strength_value"
	# To calibrate
	$Strength_Button.text = str(strength_value)

func _on_Strength_Button_button_down():
	if strength_value < 25:
		strength_value += 1

func _on_Decrease_Strength_timeout():
# the strength_value needs to be positive
	if strength_value > 0:
		strength_value -= 1

func _on_Exit_button_down():
	AUDIO.play_se("EXIT_MENU")
	get_tree().quit()

# the game starts
func _on_Start_Timer_timeout():
	get_tree().paused = false
	$GO.visible = true
	$Game_Timer.start()
	$Decrease_Strength.start()

# the game finishes
func _on_Game_Timer_timeout():
	get_tree().paused = true
	if strength_value == 25:
		$Win_Label.visible = true
	else:
		$Lose_Label.visible = true