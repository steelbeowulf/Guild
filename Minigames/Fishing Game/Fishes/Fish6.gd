extends Area2D

const speed: int = 100

onready var Death_Timer = $Death_Timer
onready var Moviment_Timer = $Moviment_Timer

var RNG = RandomNumberGenerator.new()
var death_time: float
var movement: int
var initial_position = Vector2(0,0)
var direction: int = 0   # 1 inverts axis x and y 
var velocity: Vector2

signal fish_catched

#initialize my random number
func _ready():
	RNG.randomize()
	movement = RNG.randi_range(1,5)
	position = initial_position
	connect("fish_catched",get_parent(),"Fish_catched")

#variable curve
func _physics_process(delta):
	velocity = calcule_velocity(movement)
	position += velocity*delta

#generate the fish velocity based in moviment value
func calcule_velocity(movement : float) -> Vector2:
	var velocity_: Vector2
	death_time = Death_Timer.wait_time - Death_Timer.time_left
	#fish 1 movement
	if movement == 1:
		velocity_[direction] = speed
		velocity_[(direction + 1)%2] = 0
	#fish 2 movement
	elif movement == 2:
		velocity_[direction] = speed*death_time
		velocity_[(direction + 1)%2] = speed*sin(death_time)
	#fish 3 movement
	elif movement == 3:
		velocity_[direction] = speed*(death_time - sin(death_time))
		velocity_[(direction + 1)%2] = speed*(1 - cos(death_time))
	#fish 4 movement
	elif movement == 4:
		velocity_[direction] = speed*(cos(death_time) + death_time*cos(death_time))
		velocity_[(direction + 1)%2] = speed*(sin(death_time) - death_time*cos(death_time))
	#fish 5 movement
	else:
		velocity_[direction] = speed*death_time
		velocity_[(direction + 1)%2] = speed*exp(-0.5*death_time)*cos(10*death_time)
	return velocity_

func _on_Moviment_Timer_timeout():
	movement = RNG.randi_range(1,5)

func _on_Death_Timer_timeout():
	print("morte!")
	queue_free()

func _on_Fish6_area_entered(area):
	emit_signal("fish_catched",6)
	queue_free()
