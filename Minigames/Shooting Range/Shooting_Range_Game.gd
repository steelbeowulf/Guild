extends Node2D

var arrow = load("res://Minigames/Shooting Range/Arrow.tscn")
var target = load("res://Minigames/Shooting Range/Target.tscn")
var counter : int = 0  #number of targets in the scene
var hit_counter: int = 0
var positionx_array = []
var positiony_array = []
const timer_speed: float = 0.976
onready var Bow_Position = $Bow_Position
onready var Time = $Time
onready var Target_Timer = $Target_Timer
onready var RNG = RandomNumberGenerator.new()  #generate pseudo-random numbers

func _ready():
	RNG.randomize()
	get_tree().paused = true

#print the time left in the screen
func _process(delta):
	var time_left = $End_Timer.time_left
	Time.text = str(int(time_left))

# the game starts
func _on_Start_Timer_timeout():
	get_tree().paused = false
	$GO.visible = true
	AUDIO.initSound()
	AUDIO.play_bgm("MINIGAME_THEME")

func _unhandled_input(event):
	var Shot_Timer = $Shot_Timer
	var Bow_Timer = $Bow_Timer
	var speed = 700.0
	var projectile = arrow.instance()
	if event is InputEventMouseButton:
		if event.is_action_pressed("shot"):
			#player have 5 seconds to shot or the arrow will be fired alone
			Bow_Timer.start(0)
		# when the player realeases the left mouse button the arrow will be shot by the bow
		#the Shot_Timer is used to control the number of arrows in screen per second
		if event.is_action_released("shot") and Shot_Timer.is_stopped():
			Bow_Timer.stop()
			Shot_Timer.start()
			projectile.global_position = Bow_Position.global_position
			projectile.velocity = ((get_global_mouse_position() - Bow_Position.global_position).normalized())*speed
			add_child(projectile)

# the arrow will be fired alone
func _on_Bow_Timer_timeout():
	var speed = 600.0
	var projectile = arrow.instance()
	projectile.global_position = Bow_Position.global_position
	projectile.velocity = ((get_global_mouse_position() - Bow_Position.global_position).normalized())*speed
	add_child(projectile)

#instance the Target
func _on_Target_Timer_timeout():
	var positionx : float = 0
	var positiony : float = 0
	var target_ = target.instance()
	#random position
	positionx = RNG.randf_range(40.0,1880.0)
	positiony = RNG.randf_range(40.0,1040.0)
	target_.global_position = Calculate_Target_Position(positionx, positiony)
	#store the array_position of the target in positionx(y)_array
	target_.array_position = counter - 1
	Target_Timer.wait_time *= timer_speed
	add_child(target_)

func Calculate_Target_Position(positionx: float, positiony: float):
	var target_position = Vector2(0,0)
	# check if exists another target in the same position
	for i in range(counter):
		if positionx_array[i] - 80 <= positionx and positionx <= positionx_array[i] + 80:
			if positiony_array[i] - 80 <= positiony and positiony <= positiony_array[i] + 80:
					#exists a target in same position so choose another random position and try again 
					positionx = RNG.randf_range(40.0,1880.0)
					positiony = RNG.randf_range(40.0,1040.0)
					target_position = Calculate_Target_Position(positionx,positiony)
					return target_position
	counter += 1
	#put the new position in the array
	positionx_array.push_back(positionx)
	positiony_array.push_back(positiony)
	target_position = Vector2(positionx,positiony)
	return target_position

# for each hit the hits_counter increase in one
func change_hits_counter():
	AUDIO.play_se("ARROW_HIT")
	var Hits_counter = $Hits_counter
	hit_counter += 1
	Hits_counter.text = "Hits: " + str(hit_counter)

# the game ends 
func _on_End_Timer_timeout():
	var End_MiniGame = $End_MiniGame
	End_MiniGame.visible = true
	End_MiniGame._end(hit_counter)
	get_tree().paused = true

func _on_Quit_button_down():
	get_tree().quit()