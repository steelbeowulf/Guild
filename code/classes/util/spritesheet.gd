tool

extends Sprite

export(String) var physical_frames = "1,3,5-7" setget _set_frames_str
export(int) var frame_count = 5 setget _set_frame_count
export(bool) var fix_fps = true setget _set_fix_fps
export(float) var fps = 5 setget _set_fps
export(float) var frame_period = 0.2 setget _set_frame_period  # frame_period = 1/fps
export(bool) var fix_duration = false setget _set_fix_duration
export(float) var duration = 1 setget _set_duration  # duration = frame_count * frame_period

export var playing = true setget _set_playing
export var loop = false
export var current_frame = 0 setget _set_current_frame

var frame_sequence = PoolIntArray()
var elapse_time = 0
export var editor_preview = true
var on_loading_editor = true

signal animation_finished


func _set_playing(value):
	playing = value
	if Engine.editor_hint && playing == true:
		play(true)


func _enter_tree():
	on_loading_editor = false
	_set_frames_str(physical_frames)


func _set_frames_str(value):
	var pool = get_int_list(value)
	if pool == null || pool.size() == 0:
		return

	physical_frames = value
	frame_sequence = pool

	current_frame = 0
	frame_count = frame_sequence.size()
	_update_fps_and_duration()
	property_list_changed_notify()


func _set_frame_count(value):  # read-only
	pass


func _set_fix_fps(value):
	fix_fps = value
	fix_duration = !fix_fps
	property_list_changed_notify()


func _set_fix_duration(value):
	fix_duration = value
	fix_fps = !fix_duration
	property_list_changed_notify()


func _set_fps(value):
	if value == null || value <= 0:
		return

	if Engine.editor_hint && on_loading_editor && !fix_fps:
		return

	fps = float(value)
	_set_fix_fps(true)

	_update_fps_and_duration()
	property_list_changed_notify()


func _set_frame_period(value):  # read-only
	pass


func _set_duration(value):
	if value == null || value <= 0:
		return

	if Engine.editor_hint && on_loading_editor && !fix_duration:
		return

	duration = float(value)
	_set_fix_duration(true)

	_update_fps_and_duration()
	property_list_changed_notify()


func _update_fps_and_duration():
	if fix_fps:
		duration = frame_count / fps
	else:
		fps = frame_count / duration

	frame_period = 1.0 / fps


func _set_current_frame(value):
	if value < 0 || value >= frame_sequence.size():
		return
	current_frame = value
	self.frame = frame_sequence[current_frame]  # update sprite image


func _process(delta):
	if Engine.editor_hint && !editor_preview:
		return

	if !playing:
		return

	elapse_time += delta
	var dif = elapse_time - frame_period
	if dif >= 0:
		elapse_time = dif
		var have_next = _next_frame()
		if !have_next:
			stop()
		property_list_changed_notify()


# return true when have next frame
# return false when at the last frame and not loop
func _next_frame():
	if frame_count == 0:
		return false  # should not have this case

	if current_frame >= frame_count - 1:
		if !loop:
			#self.get_parent().get_parent()._on_Sprite_animation_finished(self.name)
			emit_signal("animation_finished", self.name)
			#self.hide()
			return false  # no next frame
		else:
			self.current_frame = 0
			#self.get_parent().get_parent()._on_Sprite_animation_finished(self.name)
			#emit_signal("animation_finished", self.name)
	else:
		self.current_frame += 1

	return true


func reset():
	self.current_frame = 0
	elapse_time = 0


func play(from_start = false):
	if from_start:
		reset()
	playing = true


func play_new(new_frames_str, new_fps):
	stop(true)
	_set_frames_str(new_frames_str)
	_set_fps(new_fps)
	play()


func pause_toggle():
	if playing:
		stop()
	else:
		play()


# pause at the current frame
# But, if the reset is true, will go to the first frame
func stop(reset = false):
	playing = false
	if reset:
		reset()


func step():
	_next_frame()
	elapse_time = 0


func seek_frame(i):
	self.current_frame = i


############## Library ###############
# list : ex. 1-4, 8, 10, 12-15, 9
# return PoolIntArray
static func get_int_list(list):
	var pool = PoolIntArray()

	list = list.replace(" ", "")
	var split = list.split(",")

	var a = []

	for data in split:
		var hyphen = data.find("-")
		if hyphen != -1:  # found ( n1-n2 )
			var nums = data.split("-")
			if nums.size() != 2:
				return null
			if !nums[0].is_valid_integer() || !nums[1].is_valid_integer():
				return
			for s in range(nums[0], int(nums[1]) + 1):
				pool.append(int(s))
		else:
			if !data.is_valid_integer():
				return null
			pool.append(int(data))
	return pool
