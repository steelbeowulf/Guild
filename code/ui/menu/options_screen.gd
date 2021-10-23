extends Control

const OPTIONS_TEXT = [
	"Configures screen resolution",
	"Display mode",
	"Base volume",
	"Sound effects volume",
	"Music volume",
	"Font size",
	"Dialogue text speed",
	"Battle animations speed",
	"Default battle cursor behaviour"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for option in $Overview/Values.get_children():
		option.connect("pressed", self, "set_text", [i])
		i += 1

	for opt in DISPLAY.get_available_resolutions():
		$Overview/Values/Resolution.add_item(opt)

	$Overview/Values/Resolution.selected = DISPLAY.get_current_res()

	for opt in DISPLAY.get_modes():
		$Overview/Values/Display.add_item(opt)

	$Overview/Values/Display.selected = DISPLAY.get_current()

	for opt in BATTLE_MANAGER.get_speed_opts():
		$Overview/Values/Battle_speed.add_item(opt)

	$Overview/Values/Battle_speed.selected = BATTLE_MANAGER.get_speed()

	for opt in BATTLE_MANAGER.get_cursor_opts():
		$Overview/Values/Battle_cursor.add_item(opt)

	$Overview/Values/Battle_cursor.selected = BATTLE_MANAGER.get_cursor()

	for opt in TEXT.get_size_opts():
		$Overview/Values/Text_size.add_item(opt)

	$Overview/Values/Text_size.selected = TEXT.get_size_id()

	for opt in TEXT.get_speed_opts():
		$Overview/Values/Text_speed.add_item(opt)

	$Overview/Values/Text_speed.selected = TEXT.get_speed_id()

	$Overview/Values/Volume.set_value(AUDIO.get_master_volume())
	$Overview/Values/BGM.set_value(AUDIO.get_bgm_volume())
	$Overview/Values/SFX.set_value(AUDIO.get_sfx_volume())


func set_text(index):
	$Top_Panel/Description.set_text(OPTIONS_TEXT[index])


func _on_Resolution_item_selected(index: int):
	DISPLAY.set_resolution(index)


func _on_Display_item_selected(index: int):
	DISPLAY.set_mode(index)


func _on_Volume_value_changed(value: float):
	AUDIO.set_master_volume(value)


func _on_SFX_value_changed(value: float):
	AUDIO.set_sfx_volume(value)


func _on_BGM_value_changed(value: float):
	AUDIO.set_bgm_volume(value)


func _on_Text_size_item_selected(index: int):
	TEXT.set_size(index)


func _on_Text_speed_item_selected(index: int):
	TEXT.set_speed(index)


func _on_Battle_speed_item_selected(index: int):
	BATTLE_MANAGER.set_battle_speed(index)


func _on_Battle_cursor_item_selected(index: int):
	BATTLE_MANAGER.set_cursor_default(index)
