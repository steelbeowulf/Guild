extends Node2D

var buffer = []
var timeout = false


func _ready():
	hide()
	$Label.set_text("")


func store_text(text: String):
	buffer.append(text)


func is_empty():
	return $Label.get_text() == ""


func display_text(text: String):
	if text:
		show()
		if is_empty():
			$Label.set_text(text)
			$Timer.start()
		else:
			store_text(text)


func _on_Timer_timeout():
	$Label.set_text("")
	if buffer:
		var txt = buffer[0]
		buffer.remove(0)
		display_text(txt)
	else:
		hide()
