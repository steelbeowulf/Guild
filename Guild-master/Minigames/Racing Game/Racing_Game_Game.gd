extends Node2D

onready var Boost_Timer = $Boost_Timer
onready var Player_Car = $Player_Car
onready var Fuel_Label = $Fuel_Label
onready var Slip_Timer = $Slip_Timer
onready var Score_Label = $Score_Label
var fuel: int = 0
var score: int = 0

func _on_Button_button_down():
	get_tree().quit()

#activate boost
func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("Boost") and fuel != 0:
			Player_Car.speed = 400.0
			Boost_Timer.start()
			fuel -= 1
			Fuel_Label.text = "Fuel: " + str(fuel)
			print("oia q velocidade meu!")

#boost end
func _on_Boost_Timer_timeout():
	Player_Car.speed = 200.0

#when the player entered in the fuel's area he gets more 1 fuel to use the boost
func fuel_plus() -> void:
	print("Eba mais gasolina!")
	fuel += 1
	Fuel_Label.text = "Fuel: " + str(fuel)

#when the player entered the car will slip, 
#then the speed is increase and the car will not follow the cursor
func car_slipped() -> void:
	# rotation in radians of the velocity
	var slip_rotation: float
	print("Vish estou escorregando!")
	#is the boost is active the slip effecet will be different
	if Boost_Timer.is_stopped():
		slip_rotation = rand_range(PI/12,PI/6)
	else:
		slip_rotation = rand_range(PI/6,PI/2)
	Player_Car.speed = 900.0
	Player_Car.slip_rotation = slip_rotation
	Slip_Timer.start()

#end of the slip 
func _on_Slip_Timer_timeout():
	Player_Car.speed = 300.0
	Player_Car.slip_rotation = 0.0

func player_death():
	$Death_Label.visible = true
	get_tree().paused = true

#change the player's score
func change_score(amount):
	score += amount
	Score_Label.text = "Score: " + str(score)