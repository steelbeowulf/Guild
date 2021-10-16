class_name Shop
extends Event

var goods: Array
var subtype: String


func _init(type_arg: String, goods_arg: Array):
	self.goods = goods_arg
	self.type = "SHOP"
	self.subtype = type_arg


func get_subtype():
	return self.subtype


func get_goods():
	return self.goods
