extends Node2D

var arrow = load("res://Minigames/Shooting Range/Arrow.tscn")
var target = load("res://Minigames/Shooting Range/Target.tscn")
onready var Bow_Position = $Bow_Position
onready var Bow_Timer = $Bow_Timer
onready var Shot_Timer = $Shot_Timer

func _ready():
	get_tree().paused = true

# the game starts
func _on_Start_Timer_timeout():
	get_tree().paused = false
	$GO.visible = true
	AUDIO.initSound()
	AUDIO.play_bgm("MINIGAME_THEME")

func _unhandled_input(event):
	var speed = 500.0
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
	var speed = 500.0
	var projectile = arrow.instance()
	projectile.global_position = Bow_Position.global_position
	projectile.velocity = ((get_global_mouse_position() - Bow_Position.global_position).normalized())*speed
	add_child(projectile)

func _on_Quit_button_down():
	get_tree().quit()
