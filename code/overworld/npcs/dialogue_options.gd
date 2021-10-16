extends Control

var options = {}


func _ready():
	for opt in $Options.get_children():
		opt.add_font_override("font", TEXT.get_font())
	EVENTS.register_node("DialogueOptions", self)


func show_options():
	$Options.get_child(0).grab_focus()
	self.show()


func push_option(opt):
	var option_button = $Options.get_child(options.size())
	options[opt.get_option()] = opt.get_results()
	option_button.show()
	option_button.set_text(opt.get_option())
	option_button.disconnect("pressed", self, "on_option_selected")
	option_button.connect("pressed", self, "on_option_selected", [opt.get_option()])


func on_option_selected(option: String):
	print("[OPTION] ", option, " selected!")
	self.hide()
	for opt in $Options.get_children():
		opt.hide()
	EVENTS.play_events(options[option])
	options = {}
