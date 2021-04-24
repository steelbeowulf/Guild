extends Control

var options = {}

func _ready():
	for opt in $Options.get_children():
		opt.add_font_override("font", TEXT.get_font())
	EVENTS.register_node("DialogueOptions", self)

func push_option(opt):
	self.show()
	var optionBtn = $Options.get_child(options.size())
	options[opt.get_option()] = opt.get_results()
	optionBtn.show()
	optionBtn.set_text(opt.get_option())
	optionBtn.disconnect("pressed", self, "_on_Option_Selected")
	optionBtn.connect("pressed", self, "_on_Option_Selected", [opt.get_option()])

func _on_Option_Selected(option: String):
	print("[OPTION] ", option, " selected!")
	pass
	#EVENTS.play_dialogue(options[option])
