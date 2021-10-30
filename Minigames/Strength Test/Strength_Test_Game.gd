extends Node2D

# with this var and these 2 functions I control the quantify the strength 
var strength_value = 0
onready var Strength_Button = $Strength_Button

func _ready():
	# test
	#AUDIO.initSound()
	#AUDIO.play_bgm("MINIGAME_THEME")
	get_tree().paused = true

func _process(_delta):
	#$Bar_color.animation = "Idle" + "strength_value"
	# To calibrate
	Strength_Button.text = str(strength_value)

func _on_Strength_Button_button_down():
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
	var End_MiniGame = $End_MiniGame
	End_MiniGame.visible = true
	End_MiniGame._end(strength_value)
	get_tree().paused = true