extends Button

func set_name(name: String):
	$Name.set_text(name)

func set_cost(cost: int):
	$Cost.set_text(str(cost)+"G")