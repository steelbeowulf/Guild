extends Node

# Streams on which we'll play tue audio
var music = null
var audio = []
var prev_pos = 0.0

# Loads all our songs and SFXs
var MENU_THEME = load("res://Assets/BGM/TownTheme (online-audio-converter.com).ogg")
var MAP_THEME = load("res://Assets/BGM/Lonely Witch (online-audio-converter.com).ogg")
var BATTLE_THEME = load("res://Assets/BGM/Modern Castle - Tension (online-audio-converter.com).ogg")
var GAME_OVER_THEME = load("res://Assets/BGM/Game over jingle 4.wav")
var BOSS_THEME = load("res://Assets/BGM/Heavy Concept A Bass Master (online-audio-converter.com).ogg")
var MINIGAME_THEME = load("res://Assets/BGM/Enchanted Festival Loop.wav")
var SPELL = load("res://Assets/SFX/Powerup 4 - Sound effects Pack 2.ogg")
var RUN = load("res://Assets/SFX/Fantozzi-SandL1.ogg")
var HIT = load("res://Assets/SFX/Explosion 3 - Sound effects Pack 2.ogg")
var ENTER_MENU = load("res://Assets/SFX/Menu Confirm.ogg")
var EXIT_MENU = load("res://Assets/SFX/Menu Error.ogg")
var MOVE_MENU = load("res://Assets/SFX/Menu Move.ogg")
var MONEY = load("res://Assets/SFX/338260__philsavlem__money-bag.wav")
var GRASS = load("res://Assets/SFX/151229__owlstorm__grassy-footstep-2.wav")
var WHISTLE = load("res://Assets/SFX/320140__owlstorm__attention-whistle.wav")
var BAIT_SPLASH = load("res://Assets/SFX/splash1.wav")
var BAIT_EATED = load("res://Assets/SFX/crunch.1.wav")
var FUEL_CATCH = load("res://Assets/SFX/Item Collected.wav")
var HOLE = load("res://Assets/SFX/187569__evinawer__fall-on-the-floor-v.wav")
var BLOCK = load("res://Assets/SFX/impact.2.ogg")
var FUEL_BOOST = load("res://Assets/SFX/boost.wav")
var TIRE_SQUEAL = load("res://Assets/SFX/tire_squeal.wav")
var STAR = load("res://Assets/SFX/shimmer_1.wav")
var ARROW_HIT = load("res://Assets/SFX/arrowHit01.wav")
var BELL_SOUND = load("res://Assets/SFX/Bell-Sounds.wav")

# Variables used to play sounds
var songs = {'MENU_THEME':MENU_THEME, 'MAP_THEME':MAP_THEME, 'BATTLE_THEME':BATTLE_THEME,
'GAME_OVER_THEME':GAME_OVER_THEME, 'BOSS_THEME':BOSS_THEME, 'MINIGAME_THEME': MINIGAME_THEME}
var sounds = {'SPELL':SPELL, 'RUN':RUN, 'HIT':HIT,
'ENTER_MENU': ENTER_MENU, 'EXIT_MENU':EXIT_MENU, 'MOVE_MENU':MOVE_MENU,
'MONEY': MONEY, 'GRASS': GRASS, 'WHISTLE': WHISTLE, 'BAIT_SPLASH': BAIT_SPLASH, 
'BAIT_EATED': BAIT_EATED, 'FUEL_CATCH': FUEL_CATCH, 'HOLE': HOLE, 'BLOCK': BLOCK,
'FUEL_BOOST': FUEL_BOOST, 'TIRE_SQUEAL': TIRE_SQUEAL, 'STAR': STAR , 
'ARROW_HIT': ARROW_HIT, 'BELL_SOUND': BELL_SOUND}

# Base volumes
onready var base_master = -10
onready var base_bgm = 4
onready var base_se = 12


# Initializes or resets the sounds system
func initSound():
	if audio.size() == 0:
		for i in range(20):
			audio.push_back(AudioStreamPlayer.new())
			self.add_child(audio[i])
			audio[i].volume_db = base_master
			audio[i].pause_mode = PAUSE_MODE_PROCESS
	else:
		audio[0].stop()
	if music == null:
		music = AudioStreamPlayer.new()
		self.add_child(music)
		music.stream = MENU_THEME
		music.volume_db = base_master + base_bgm
		music.play()
		music.pause_mode = PAUSE_MODE_PROCESS
	elif music.stream != MENU_THEME:
		music.stream = MENU_THEME
		music.volume_db = base_master + base_bgm
		music.play()
	else:
		return


# Resets the volume on all audio streams
func recalibrate():
	music.volume_db = base_master + base_bgm
	for i in range(20):
		audio[i].volume_db = base_master + base_se


# Stops playing a BGM
func stop_bgm():
	if music.stream == songs['MAP_THEME']:
		prev_pos = music.get_playback_position()
	music.stop()


# Plays a bgm. If a keep argument is sent, it will continue playing
# the song from current position
func play_bgm(bgm, keep=false, loud=0):
	var play = 0.0
	if music.stream == songs['MAP_THEME']:
		prev_pos = music.get_playback_position()
	music.stream = songs[bgm]
	music.volume_db = base_master + base_bgm + loud
	if keep:
		play = prev_pos
	music.play(play)


# Plays a sound effect. The loud argument is an extra to raise volume.
func play_se(sound, loud=0):
	sound = sounds[sound]
	for i in range(20):
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
