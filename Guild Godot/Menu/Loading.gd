var loader
var wait_frames
var time_max = 100 # msec
var current_scene

func _ready(): # game requests to switch to this scene
	var path = GLOBAL.NEXT_SCENE
    loader = ResourceLoader.load_interactive(path)
    if loader == null: # check for errors
        show_error()
        return
    set_process(true)

    current_scene.queue_free() # get rid of the old scene

    # start your "loading..." animation
    get_node("animation").play("loading")

    wait_frames = 1


func _process(time):
    if loader == null:
        # no need to process anymore
        set_new_scene()
        queue_free()

    if wait_frames > 0: # wait for frames to let the "loading" animation to show up
        wait_frames -= 1
        return

    var t = OS.get_ticks_msec()
    while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread

        # poll your loader
        var err = loader.poll()

        if err == ERR_FILE_EOF: # load finished
            var resource = loader.get_resource()
            loader = null
            set_new_scene(resource)
            break
        elif err == OK:
            update_progress()
        else: # error during loading
            show_error()
            loader = null
            break


func update_progress():
    var progress = float(loader.get_stage()) / loader.get_stage_count()
    # update your progress bar?
    get_node("Progress").set_progress(progress)


func set_new_scene(scene_resource):
    current_scene = scene_resource.instance()
    get_node("/root").add_child(current_scene)