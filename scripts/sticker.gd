extends Control
class_name Sticker

var object_data: BreakableObjectData

func spawn(object_data: BreakableObjectData):
	name = object_data.item_name
	$Texture.texture = object_data.sprite
