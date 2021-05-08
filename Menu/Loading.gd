extends Node
var loader
var resource
var wait_frames
var time_max = 100 # msec
var current_scene

var ROOT_SCENE = "res://Root.tscn"

func _ready(): # game requests to switch to this scene
	var loader_class = get_tree().get_root().get_node("LOADER")
	var lore = loader_class.get_random_lore()
	$Panel/Sprite.set_texture(load(lore["Image"]))
	$Panel/Text.set_text(lore["Text"])
	$Panel/Title.set_text(lore["Title"])

	loader = ResourceLoader.load_interactive(ROOT_SCENE)
	if loader == null: # check for errors
		print("[LOADER] Erro ao carregar")
		return

	wait_frames = 10


func _physics_process(delta):
	if loader == null:
		update_progress(100)
		if Input.is_action_just_pressed("ui_accept"):
			AUDIO.play_se("ENTER_MENU")
			set_new_scene(resource)
		return

	if wait_frames > 0: # wait for frames to let the "loading" animation to show up
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread

		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # load finished
			#print("Loading finished!")
			update_progress(100)
			$Panel/Prompt.show()
			resource = loader.get_resource()
			loader = null
			break
		elif err == OK:
			var progress = (float(loader.get_stage()) / loader.get_stage_count()) * 100
			update_progress(progress)
		else: # error during loading
			#print("LOADER - deu ruim")
			loader = null
			break


func update_progress(progress):
	get_node("Progress").set_value(progress)


func set_new_scene(scene_resource):
	get_tree().change_scene(ROOT_SCENE)
