extends Node2D

const SOLUTION = ['yellow', 'pink', 'dark blue', 'purple', 'orange', 'green', 'green', 'dark blue', 'pink', 'orange', 'purple', 'yellow']
const LEFT_INITIAL = ['green', 'dark blue', 'pink', 'orange', 'purple', 'yellow']
const RIGHT_INITIAL = ['yellow', 'pink', 'dark blue', 'purple', 'orange', 'green']

const color = {'green': Color(0.14902, 0.752941, 0.098039), 'dark blue': Color(0.031373, 0.062745, 0.419608),
'pink':Color(0.701961, 0.133333, 0.34902), 'orange':Color(0.905882, 0.537255, 0.105882), 
'purple':Color(0.396078, 0.098039, 0.752941), 'yellow':Color(0.733333, 0.752941, 0.098039)}

const cicle = [Color(0.14902, 0.752941, 0.098039), Color(0.031373, 0.062745, 0.419608),
Color(0.701961, 0.133333, 0.34902), Color(0.905882, 0.537255, 0.105882), 
Color(0.396078, 0.098039, 0.752941),  Color(0.733333, 0.752941, 0.098039)]

func reset():
	var i = 1
	for tile in $Left.get_children():
		tile.color = color[LEFT_INITIAL[i-1]]
		i+=1
	i = 1
	for tile in $Right.get_children():
		tile.color = color[RIGHT_INITIAL[i-1]]
		i+=1

func check_colors():
	var i = 1
	while i < 7:
		var tile = get_node("Left/Tile"+str(i))
		if tile.color != color[SOLUTION[i-1]]:
			return false
		i+=1
	while i < 13:
		var tile = get_node("Right/Tile"+str(i))
		if tile.color != color[SOLUTION[i-1]]:
			return false
		i+=1
	return true

func _process(delta):
	if check_colors() and not GLOBAL.MATCH:
		print("YAY!!")
		GLOBAL.MATCH = true
		get_parent().send_message("Uma nova passagem se abriu!")

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 1
	for tile in $Left.get_children():
		var area = tile.get_child(0)
		area.connect('body_entered', self, '_on_Body_Entered_'+str(i))
		i += 1
	for tile in $Right.get_children():
		var area = tile.get_child(0)
		area.connect('body_entered', self, '_on_Body_Entered_'+str(i))
		i += 1

func _on_Body_Entered_1(body):
	if body.is_in_group('player'):
		var current = get_node('Left/Tile1').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Left/Tile1').color = next

func _on_Body_Entered_2(body):
	if body.is_in_group('player'):
		var current = get_node('Left/Tile2').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Left/Tile2').color = next

func _on_Body_Entered_3(body):
	if body.is_in_group('player'):
		var current = get_node('Left/Tile3').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Left/Tile3').color = next
		
func _on_Body_Entered_4(body):
	if body.is_in_group('player'):
		var current = get_node('Left/Tile4').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Left/Tile4').color = next

func _on_Body_Entered_5(body):
	if body.is_in_group('player'):
		var current = get_node('Left/Tile5').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Left/Tile5').color = next

func _on_Body_Entered_6(body):
	if body.is_in_group('player'):
		var current = get_node('Left/Tile6').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Left/Tile6').color = next

func _on_Body_Entered_7(body):
	if body.is_in_group('player'):
		var current = get_node('Right/Tile7').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Right/Tile7').color = next

func _on_Body_Entered_8(body):
	if body.is_in_group('player'):
		var current = get_node('Right/Tile8').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Right/Tile8').color = next

func _on_Body_Entered_9(body):
	if body.is_in_group('player'):
		var current = get_node('Right/Tile9').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Right/Tile9').color = next
		
func _on_Body_Entered_10(body):
	if body.is_in_group('player'):
		var current = get_node('Right/Tile10').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Right/Tile10').color = next

func _on_Body_Entered_11(body):
	if body.is_in_group('player'):
		var current = get_node('Right/Tile11').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Right/Tile11').color = next

func _on_Body_Entered_12(body):
	if body.is_in_group('player'):
		var current = get_node('Right/Tile12').color
		var idx = cicle.find(current)
		var next = cicle[(idx+1)%6]
		get_node('Right/Tile12').color = next