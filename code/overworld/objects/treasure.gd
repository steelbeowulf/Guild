extends StaticBody2D

export(int) var item_id
export(int) var item_quantity

var body_entered = false
var closed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if body_entered and closed:
		if Input.is_action_just_pressed("ui_accept"):
			GLOBAL.add_item(item_id, item_quantity)
			var name = GLOBAL.itens[item_id].name
			closed = false
			$Sprite.frame = 3
			get_parent().get_parent().send_message(
				"Encontrou " + name + " x" + str(item_quantity + 1)
			)
			get_parent().get_parent().save_state("TREASURE", self.get_name())


func _on_Area2D_area_entered(area: Area2D):
	if area.is_in_group("head"):
		body_entered = true


func update_state(value: bool):
	if value:
		closed = false
		$Sprite.frame = 3


func _on_Area2D_area_exited(area: Area2D):
	if area.is_in_group("head"):
		body_entered = false
