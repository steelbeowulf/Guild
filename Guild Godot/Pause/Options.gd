extends Control

const options_text = [
	"Configura resolução da tela",
	"Modo de display",
	"Volume base",
	"Volume dos efeitos sonoros",
	"Volume da música",
	"Tamanho da fonte",
	"Velocidade do texto",
	"Velocidade das animações de batalha",
	"Posição padrão do cursor em batalha"]

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for option in $Overview/Values.get_children():
		option.connect("pressed", self, "set_text", [i])
		i += 1
	
	for opt in DISPLAY.get_available_resolutions():
		$Overview/Values/Resolution.add_item(opt)
	
	for opt in DISPLAY.get_modes():
		$Overview/Values/Display.add_item(opt)


func set_text(index):
	$Top_Panel/Description.set_text(options_text[index])


func _on_Resolution_item_selected(ID):
	DISPLAY.set_resolution(ID)


func _on_Display_item_selected(ID):
	DISPLAY.set_mode(ID)


func _on_Volume_value_changed(value):
	AUDIO.set_master_volume(value)


func _on_SFX_value_changed(value):
	AUDIO.set_sfx_volume(value)


func _on_BGM_value_changed(value):
	AUDIO.set_bgm_volume(value)


func _on_Text_size_item_selected(ID):
	#TEXT.set_font_size(ID)
	pass


func _on_Text_speed_item_selected(ID):
	#TEXT.set_text_speed(ID)
	pass


func _on_Battle_speed_item_selected(ID):
	BATTLE_MANAGER.set_battle_speed(ID)


func _on_Battle_Cursor_item_selected(ID):
	BATTLE_MANAGER.set_cursor_default(ID)
