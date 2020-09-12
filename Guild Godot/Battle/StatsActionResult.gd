extends ActionResult
class_name StatsActionResult

var stats_change : Array
var deaths : PoolIntArray
var targets : Array
var spell : Item

func _init(type_arg: String, targets_arg: Array, 
			stats_arg: Array, deaths_arg: PoolIntArray,
			spell_arg = null):
	self.type = type_arg
	self.stats_change = stats_arg
	self.deaths = deaths_arg
	self.spell = spell_arg
	self.targets = targets_arg

func get_type() -> String:
	return type

func get_stats_change() -> Array:
	return stats_change

func get_deaths() -> PoolIntArray:
	return deaths

func get_targets() -> Array:
	return targets

func get_spell() -> Item:
	return spell