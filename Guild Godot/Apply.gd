extends Node

#["MP", 1.5, 5]

func apply_effect(effect, target):
	var stat = effect[0]
	var value = effect[1]
	var TargetStat = target.get_stats(stat)
	target.set_stats(stat, TargetStat+value)
	
func apply_status(status, target):
	pass