extends Node2D

var buf = []

func _ready():
	$Label.set_text("")

func store_text(text):
	buf.append(text)

func is_empty():
	return $Label.get_text() == ""

func display_text(text):
	if text:
		if is_empty():
			$Label.set_text(text)
			$Timer.start()
		else:
			store_text(text)

func _on_Timer_timeout():
	$Label.set_text("")
	print("timeot")
	if buf:
		var txt = buf[0]
		buf.remove(0)
		display_text(txt)
