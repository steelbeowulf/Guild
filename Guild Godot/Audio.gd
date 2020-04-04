extends Node

# Streams on which we'll play tue audio
var music = null
var audio = []
var prev_pos = 0.0

# Loads all our songs and SFXs
var MENU_THEME = load("res://Musics/TownTheme (online-audio-converter.com).ogg")
var MAP_THEME = load("res://Musics/Lonely Witch (online-audio-converter.com).ogg")
var BATTLE_THEME = load("res://Musics/Modern Castle - Tension (online-audio-converter.com).ogg")
var GAME_OVER_THEME = load("res://Musics/Game over jingle 4.wav")
var BOSS_THEME = load("res://Musics/Heavy Concept A Bass Master (online-audio-converter.com).ogg")
var SPELL = load("res://Audio bits/Powerup 4 - Sound effects Pack 2.ogg")
var RUN = load("res://Audio bits/Fantozzi-SandL1.ogg")
var HIT = load("res://Audio bits/Explosion 3 - Sound effects Pack 2.ogg")

# Variables used to play sounds
var songs = {'MENU_THEME':MENU_THEME, 'MAP_THEME':MAP_THEME, 'BATTLE_THEME':BATTLE_THEME,
'GAME_OVER_THEME':GAME_OVER_THEME, 'BOSS_THEM':BOSS_THEME}
var sounds = {'SPELL':SPELL, 'RUN':RUN, 'HIT':HIT}

# Base volumes
onready var base_master = -10
onready var base_bgm = 0
onready var base_se = 0


# Initializes or resets the sounds system
func initSound():
	if audio.size() == 0:
		for i in range(10):
			audio.push_back(AudioStreamPlayer.new())
			self.add_child(audio[i])
			audio[i].volume_db = base_master
	else:
		audio[0].stop()
	if music == null:
		music = AudioStreamPlayer.new()
		self.add_child(music)
		music.stream = MENU_THEME
		music.volume_db = base_master -5
		music.play()
	elif music.stream != MENU_THEME:
		music.stream = MENU_THEME
		music.volume_db = base_master -5
		music.play()
	else:
		return


# Resets the volume on all audio streams
func recalibrate():
	music.volume_db = base_master + base_bgm - 10
	for i in range(10):
		audio[i].volume_db = base_master + base_se


# Stops playing a BGM
func stop_bgm():
	if music.stream == songs['MAP_THEME']:
		prev_pos = music.get_playback_position()
	music.stop()


# Plays a bgm. If a keep argument is sent, it will continue playing
# the song from current position
func play_bgm(bgm, keep=false):
	var play = 0.0
	if music.stream == songs['MAP_THEME']:
		prev_pos = music.get_playback_position()
	music.stream = songs[bgm]
	music.volume_db = base_master + base_bgm + 2
	if keep:
		play = prev_pos
	music.play(play)


# Plays a sound effect. The loud argument is an extra to raise volume.
func play_se(sound, loud=0):
	sound = sounds[sound]
	for i in range(10):
		if get_tree().paused and i >= 3:
			audio[i].playing = false
		if audio[i].playing and audio[i].stream == sound and !get_tree().paused:
			return
		elif !audio[i].playing:
			audio[i].volume_db = base_master + base_se + loud
			audio[i].stream = sound
			audio[i].play()
			return

############# CONFIG FUNCTIONS ###################
func get_master_volume():
	return base_master

func get_bgm_volume():
	return base_bgm

func get_sfx_volume():
	return base_se

func set_master_volume(vol):
	base_master = vol
	recalibrate()

func set_sfx_volume(vol):
	base_se = vol
	recalibrate()

func set_bgm_volume(vol):
	base_bgm = vol
	recalibrate()