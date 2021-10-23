extends Node

const ROOT_SCENE = "res://code/root.tscn"
const TIME_MAX = 100  # ms

var loader
var wait_frames

onready var resource = ROOT_SCENE


func _ready():  # game requests to switch to this scene
	var loader_class = get_tree().get_root().get_node("LOADER")
	var lore = loader_class.get_random_lore()
	$Panel/Sprite.set_texture(load(lore["Image"]))
	$Panel/Text.set_text(lore["Text"])
	$Panel/Title.set_text(lore["Title"])

	loader = ResourceLoader.load_interactive(ROOT_SCENE)
	if loader == null:  # check for errors
		print("[LOADER] Erro ao carregar")
		return

	wait_frames = 10


func _physics_process(_delta):
	if loader == null:
		update_progress(100)
		if Input.is_action_just_pressed("ui_accept"):
			AUDIO.play_se("ENTER_MENU")
			set_new_scene(resource)
		return

	# wait for frames to let the "loading" animation to show up
	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	# use "time_max" to control how much time we block this thread
	while OS.get_ticks_msec() < t + TIME_MAX:
		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF:  # load finished
			update_progress(100)
			$Panel/Prompt.show()
			resource = loader.get_resource()
			loader = null
			break
		elif err == OK:
			var progress = (float(loader.get_stage()) / loader.get_stage_count()) * 100
			update_progress(progress)
		else:  # error during loading
			loader = null
			break


func update_progress(progress: float):
	get_node("Progress").set_value(progress)


func set_new_scene(scene_resource: String):
	get_tree().change_scene(scene_resource)
