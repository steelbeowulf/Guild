extends StaticBody2D

var inbody = false
var closed = true
export(int) var item_id
export(int) var item_quantity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if inbody and closed:
		if Input.is_action_just_pressed("ui_accept"):
			GLOBAL.add_item(item_id, item_quantity)
			var nome = GLOBAL.ALL_ITENS[item_id].nome
			closed = false
			$Sprite.play("open")
			get_parent().get_parent().send_message("Encontrou "+nome+" x"+str(item_quantity))

func _on_Area2D_area_entered(area):
	if area.is_in_group("head"):
		inbody = true


func _on_Area2D_area_exited(area):
	if area.is_in_group("head"):
		inbody = false
