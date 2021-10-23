extends Area2D

const speed: float = 500.0

onready var path_follow = get_parent()

signal death 
signal fish_catched

func _ready():
	connect("death",get_parent().get_parent(),"_end")
	connect("fish_catched",get_parent().get_parent().get_parent(),"Fish_catched")

func _physics_process(delta):
	path_follow.set_offset(path_follow.get_offset() + speed*delta)
	if path_follow.unit_offset >= 1.0:
		emit_signal("death")

func _on_Fish_area_entered(area):
	print("peixe maluko quer me comer")
	emit_signal("fish_catched",7)
	emit_signal("death")
