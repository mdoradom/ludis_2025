extends Node
class_name StickerFactory

signal sticker_spawned(sticker: Sticker)

@export var missing_texture: Texture2D

var sticker_scene = preload("res://scenes/sticker.tscn")

func _ready() -> void:
	pass

func spawn_sticker_from_data(object_data: BreakableObjectData, pos: Vector2) -> Sticker:
	var object: Sticker = sticker_scene.instantiate()
	
	if !object_data.sprite:
		object_data.sprite = missing_texture
	
	object.spawn(object_data)
	
	sticker_spawned.emit(object)
	
	add_child(object)
	return object

func spawn_sticker_from_string(word: String, dict: WordDictionary, pos: Vector2 = Vector2.ZERO):
	var available_objects = dict
	if available_objects.has(word):
		spawn_sticker_from_data(available_objects[word], pos)
