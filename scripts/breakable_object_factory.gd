extends Node
class_name BreakableObjectFactory

"""
The responsabilities of this object are:
	- Spawn Breakable Objects
"""

signal breakable_object_spawned(b_object: BreakableObject)

var breakable_object_scene = preload("res://scenes/breakable_object.tscn")

var level_node

func _ready() -> void:
	# Important! This node should be always a child of Level
	level_node = get_parent()

func spawn_breakable_object_from_data(object_data: BreakableObjectData, pos: Vector2) -> BreakableObject:
	var object = breakable_object_scene.instantiate()
	
	object.position = pos
	object.object_data = object_data
	
	# FIXME: Fix this signal!!
	object.connect("broken", Callable(level_node, "_on_object_broken"))
	
	breakable_object_spawned.emit(object)
	
	add_child(object)
	return object

func spawn_breakable_object_from_string(word: String, pos: Vector2 = Vector2.ZERO):
	var available_objects = level_node.available_objects
	if available_objects.has(word):
		spawn_breakable_object_from_data(available_objects[word], pos)
