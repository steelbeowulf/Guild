extends KinematicBody2D

const regular_speed = 800.0
var velocity = Vector2(0,0)
var speed: float = 800.0
var slip_rotation: float = 0
var prev_player_position_x: float = 0
onready var Sprite = $Sprite
onready var Camera2D = $Camera2D
onready var camera_rect_size = Camera2D.get_viewport_rect().size

func _ready():
	#adjust Camera2D's limits and car position
	print(camera_rect_size)
	self.position.y = camera_rect_size.y/2
	Camera2D.limit_bottom = get_viewport().size.y
	Camera2D.limit_left = Camera2D.get_camera_screen_center().x - camera_rect_size.x/2

func _process(_delta):
	#prevent the player to come back in the minigame
	if prev_player_position_x < self.position.x:
		prev_player_position_x = self.position.x
		Camera2D.limit_left = Camera2D.get_camera_screen_center().x - camera_rect_size.x/2

# for each delta the car will move
func _physics_process(delta):
	var mouse = get_global_mouse_position() - self.global_position
	#see the func car_slipped() in Racing_Game_Game.gd
	mouse = mouse.rotated(slip_rotation)
	# if < 17.5 the cursor is very next to the car, then the sprite will shake
	if mouse.length() > 17.5:
		velocity = mouse.normalized()*speed
		Sprite.rotate(mouse.angle() - Sprite.global_rotation)
	else:
		velocity = Vector2(0,0)
		Sprite.rotate(0)
	move_and_slide(velocity)
