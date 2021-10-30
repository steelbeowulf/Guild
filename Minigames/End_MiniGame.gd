extends Control

#print in the screen the number of points that the palyer gets in this minigame
func _end(points):
	# if strength_value > 25:
		#AUDIO.play_se("BELL")
	$Label.text = "You get:" + str(points) + "points"

func _on_Quit_button_down():
	get_tree().quit()
