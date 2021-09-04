extends Node2D

onready var Boost_Timer = $Boost_Timer
onready var Player_Car = $Player_Car
onready var Fuel_Label = $Fuel_Label
onready var Slip_Timer = $Slip_Timer
onready var Score_Label = $Score_Label
onready var Camera = get_node("Player_Car/Camera2D")
var Obstacles_position = []
var Obstacle_counter: int = 0 #number of obstacles
var fuel: int = 0
var score: int = 0

func _on_Button_button_down():
	get_tree().quit()

#activate boost
func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("Boost") and fuel != 0:
			Player_Car.speed = Player_Car.regular_speed*3
			Boost_Timer.start()
			fuel -= 1
			Fuel_Label.text = "Fuel: " + str(fuel)
			print("oia q velocidade meu!")

#boost end
func _on_Boost_Timer_timeout():
	Player_Car.speed = Player_Car.regular_speed

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
	#is the boost or the slip mode is active the slip effect will be different
	if !Boost_Timer.is_stopped() or !Slip_Timer.is_stopped():
		slip_rotation = rand_range(PI/6,PI/2)
	else:
		slip_rotation = rand_range(PI/12,PI/6)
	Player_Car.speed = Player_Car.regular_speed*3
	Player_Car.slip_rotation = slip_rotation
	Slip_Timer.start()

#end of the slip 
func _on_Slip_Timer_timeout():
	Player_Car.speed = Player_Car.regular_speed
	Player_Car.slip_rotation = 0.0

func player_death():
	$Death_Label.visible = true
	get_tree().paused = true

#change the player's score
func change_score(amount):
	score += amount
	Score_Label.text = "Score: " + str(score)

#WARNING: i NEVER test this!
func create_map() -> void:
	var Block = load("res://Minigames/Racing Game/Block.tscn")
	var Fuel = load("res://Minigames/Racing Game/Fuel.tscn")
	var Hole = load("res://Minigames/Racing Game/Hole.tscn")
	var Oil = load("res://Minigames/RacingGame/Oil.tcsn")
	var Sprite1 = load("res://Minigames/RacingGame/Sprite1.tcsn")
	var Sprite2 = load("res://Minigames/RacingGame/Sprite2.tcsn")
	var Star = load("res://Minigames/Racing Game/Star.tscn")
	var Obstacles = [Block, Fuel, Hole, Oil, Sprite1, Sprite2, Star]
	var number_of_objects = rand_range(100,200)
	var obstacle: Object
	for i in number_of_objects:
		obstacle = Obstacles[rand_range(0,6)].new()
		#random position
		var positionx: float = rand_range(Player_Car.position.x, 
		Camera.get_camera_screen_center().x + Player_Car.camera_rect_size.x/2)
		var positiony: float = rand_range(0, Camera.limit_bottom)
		obstacle.position = get_obstacle_position(positionx, positiony)
		self.add_child(obstacle)

func get_obstacle_position(positionx: float, positiony: float) -> Vector2:
	for i in range(Obstacle_counter):
		if Obstacles_position[i].x - 200 <= positionx and positionx <= Obstacles_position[i].x + 620:
			if Obstacles_position[i].y - 200 <= positiony and positiony <= Obstacles_position[i].y + 200:
					#exists a target in same position so choose another random position and try again 
					var positionx_ : float = 0
					var positiony_ : float = 0
					positionx_ = rand_range(40,1880)
					positiony_ = rand_range(40,1040)
					get_obstacle_position(positionx_,positiony_) 
	Obstacle_counter += 1
	#put the new position in the array
	Obstacles_position.push_back(Vector2(positionx,positiony))
	return Vector2(positionx,positiony)