class_name RunActionResult
extends ActionResult

var boss: bool
var successful: bool


func _init(boss_arg: bool, success_arg: bool):
	self.type = "Run"
	self.boss = boss_arg
	self.successful = success_arg


func is_run_successful() -> bool:
	return successful


func is_boss() -> bool:
	return boss
