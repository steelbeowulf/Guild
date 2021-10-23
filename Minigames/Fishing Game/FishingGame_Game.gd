extends Node2D

onready var fish1 = load("res://Minigames/Fishing Game/Fishes/Fish1.tscn")
onready var fish2 = load("res://Minigames/Fishing Game/Fishes/Fish2.tscn")
onready var fish3 = load("res://Minigames/Fishing Game/Fishes/Fish3.tscn")
onready var fish4 = load("res://Minigames/Fishing Game/Fishes/Fish4.tscn")
onready var fish5 = load("res://Minigames/Fishing Game/Fishes/Fish5.tscn")
onready var fish6 = load("res://Minigames/Fishing Game/Fishes/Fish6.tscn")
onready var fish7 = load("res://Minigames/Fishing Game/Fishes/Fish7.tscn")
onready var fish8 = load("res://Minigames/Fishing Game/Fishes/Fish8.tscn")
onready var fish9 = load("res://Minigames/Fishing Game/Fishes/Fish9.tscn")
onready var fish10 = load("res://Minigames/Fishing Game/Fishes/Fish10.tscn")
onready var bait = load("res://Minigames/Fishing Game/Bait.tscn")
onready var Fish_Timer = $Fish_Timer
onready var Bait_Timer = $Bait_Timer
onready var Score_Label = $Score_Label
onready var Throw_Timer = $Throw_Timer
var score: int = 0
var fish_vector: Array
var bait_on_the_hook: int = 0 # when 1 you can throw a bait
var RNG = RandomNumberGenerator.new()

func _ready():
	fish_vector = [fish1, fish2, fish3, fish4, fish5, fish6, fish7, fish8, fish9, fish10]
	RNG.randomize()

func _on_Fish_Timer_timeout():
	Fish_Timer.wait_time *= 0.99
	_instance_fish()

# instance a fish based in random numbers
func _instance_fish() -> void:
	var fish: Object
	var fish_number = RNG.randi_range(0,9)
	fish = fish_vector[fish_number].instance()
	if fish_number < 6:
		fish.direction = RNG.randi_range(0,1)
		fish.initial_position[(fish.direction + 1)%2] = RNG.randi_range(50, 1100)
	elif fish_number < 9:
		fish.initial_position[0] = RNG.randf_range(10,100)
	#fish_number == 9
	else:
		fish.initial_position[0] += RNG.randf_range(-200,10)
	add_child(fish)

#player throw a bait
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("throw_bait") and bait_on_the_hook:
		bait_on_the_hook = 0
		Throw_Timer.start()

#instance the bait
func _on_Throw_Timer_timeout():
	var new_bait
	new_bait = bait.instance()
	new_bait.global_position = get_global_mouse_position()
	add_child(new_bait)

func bait_timer_start() -> void:
	Bait_Timer.start()

func _on_Bait_Timer_timeout():
	bait_on_the_hook = 1

# generate the score based on the fish difficult
func Fish_catched(fish_code: int) -> void:
	if fish_code < 7:
		score += fish_code*5
	else:
		score += 20
	update_score()

func update_score() -> void:
	Score_Label.text = "Score: " + str(score)

# game over
func _on_End_Timer_timeout():
	get_tree().quit()
