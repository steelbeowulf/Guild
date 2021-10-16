extends KinematicBody2D

const speed: float = 500.0

onready var path_follow = get_parent()
signal death 

func _ready():
	connect("death",get_parent().get_parent(),"_end")

func _physics_process(delta):
	path_follow.set_offset(path_follow.get_offset() + speed*delta)
	if path_follow.unit_offset >= 1.0:
		emit_signal("death")