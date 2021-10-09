extends ActionResult
class_name LaneActionResult

var lane: int


func _init(lane_arg: int):
	self.type = "Lane"
	self.lane = lane_arg


func get_lane() -> int:
	return lane
