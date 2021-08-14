extends Node2D

onready var Boost_Timer = $Boost_Timer
onready var Player_Car = $Player_Car
onready var Fuel_Label = $Fuel_Label
var fuel: int = 0

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
func fuel_plus():
	print("Eba mais gasolina!")
	fuel += 1
	Fuel_Label.text = "Fuel: " + str(fuel)

