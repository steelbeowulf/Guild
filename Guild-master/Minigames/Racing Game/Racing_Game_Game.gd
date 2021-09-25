extends Node2D

onready var Boost_Timer = $Boost_Timer
onready var Player_Car = $Player_Car
onready var Fuel_Label = get_node("CanvasLayer/Fuel_Label")
onready var Slip_Timer = $Slip_Timer
onready var Score_Label = get_node("CanvasLayer/Score_Label")
onready var Camera = get_node("Player_Car/Camera2D")
onready var Map_Timer = $Map_Timer
onready var End_Timer = $End_Timer
onready var End_Time_Label = get_node("CanvasLayer/End_Time_Label")
var Block = load("res://Minigames/Racing Game/Block.tscn")
var Fuel = load("res://Minigames/Racing Game/Fuel.tscn")
var Hole = load("res://Minigames/Racing Game/Hole.tscn")
var Oil = load("res://Minigames/Racing Game/Oil.tscn")
var Sprite1 = load("res://Minigames/Racing Game/Sprite1.tscn")
var Sprite2 = load("res://Minigames/Racing Game/Sprite2.tscn")
var Star = load("res://Minigames/Racing Game/Star.tscn")
var Matrix_Map = []
var Obstacles_position = []
var Obstacle_counter: int = 0 #number of obstacles
var fuel: int = 0
var score: int = 0

func _on_Button_button_down():
	get_tree().quit()

func _physics_process(_delta):
	End_Time_Label.text = "Time: " + str(End_Timer.time_left)

#activate boost
func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("Boost") and fuel != 0:
			Player_Car.speed = Player_Car.regular_speed*3
			Boost_Timer.start()
			fuel -= 1
			Fuel_Label.text = "Fuel: " + str(fuel)
			print("oia q velocidade meu!")
		if event.pressed and event.is_action_pressed("end"):
			get_tree().quit() 

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

func player_death() -> void:
	#get_node("CanvasLayer/Death_Label").visible = true
	#get_tree().paused = true
	get_tree().quit()

#change the player's score
func change_score(amount) -> void:
	score += amount
	Score_Label.text = "Score: " + str(score)

#instance the obstacles
func create_map() -> void:
	create_matrix_map()
	var Obstacles = [Block, Fuel, Hole, Oil, Sprite1, Sprite2, Star]
	var obstacle_position: Vector2
	var obstacle: Object
	obstacle = Obstacles[rand_range(0,6)].instance()
	obstacle_position = get_obstacle_position()
	while(obstacle_position == Vector2(0,0)):
		obstacle_position = get_obstacle_position()
	obstacle.global_position = obstacle_position
	add_child(obstacle)

func get_obstacle_position() -> Vector2:
	var obstacle_index = rand_range(0, 325)
	#prevent obstacle overlap
	for i in range(Obstacle_counter):
		if Matrix_Map[obstacle_index][0] == Obstacles_position[i][0] && Matrix_Map[obstacle_index][1] == Obstacles_position[i][1]:
			return Vector2(0,0)
	#put the new position in the array
	Obstacle_counter += 1
	Obstacles_position.push_back(Matrix_Map[obstacle_index])
	return Vector2(Matrix_Map[obstacle_index][0] + Player_Car.camera_rect_size.y/40,
	Matrix_Map[obstacle_index][1] + Player_Car.camera_rect_size.x/40)

func _on_Map_Timer_timeout():
	Map_Timer.wait_time *= 0.955
	create_map()

#determine the possible positions to instance a obstacle
func create_matrix_map() -> void:
	var sizey: int = Player_Car.camera_rect_size.y/20
	var sizex: int = Player_Car.camera_rect_size.x/20
	Matrix_Map = []
	for i in range(326):
		Matrix_Map.push_back([Player_Car.position.x + sizex*(i%20), 100 + sizey*(i%20)])

func _on_Victory_body_entered(body):
	print("Ganhei")
	get_tree().quit()

func _on_End_Timer_timeout():
	get_tree().quit()
