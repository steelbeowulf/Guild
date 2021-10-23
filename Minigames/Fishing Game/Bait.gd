extends Area2D

signal bait_eatead

func _ready():
	connect("bait_eatead",get_parent(),"bait_timer_start")

#the player free the bait
func _on_Button_button_down():
	emit_signal("bait_eatead")
	self.queue_free()

#the bait was eatead
func _on_Bait_area_entered(area):
	print("me comeram")
	emit_signal("bait_eatead")
	self.queue_free()
