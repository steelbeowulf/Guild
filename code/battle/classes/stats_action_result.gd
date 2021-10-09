extends ActionResult
class_name StatsActionResult

var stats_change: Array
var deaths: Array
var misses: Array
var criticals: Array
var targets: Array
var spell: Item
var actor: Entity


func _init(
	type_arg: String,
	actor_arg: Entity,
	targets_arg: Array,
	stats_arg: Array,
	deaths_arg: Array,
	spell_arg = null
):
	self.actor = actor_arg
	self.type = type_arg
	self.stats_change = stats_arg
	self.deaths = deaths_arg
	self.spell = spell_arg
	self.targets = targets_arg


func get_type() -> String:
	return type


func get_stats_change() -> Array:
	return stats_change


func get_deaths() -> Array:
	return deaths


func get_misses() -> Array:
	return misses


func get_criticals() -> Array:
	return criticals


func get_targets() -> Array:
	return targets


func get_spell() -> Item:
	return spell


func get_actor() -> Entity:
	return actor
