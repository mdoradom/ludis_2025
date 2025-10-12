extends Node

enum SCENE_LEVEL {
	NONE,
	MAIN_MENU,
	GAME,
	# ... add other scenes
}

var scene_paths = {
	SCENE_LEVEL.MAIN_MENU: "res://scenes/ui/main_menu.tscn",
	SCENE_LEVEL.GAME: "res://scenes/game/main.tscn",
	# ... add other scene paths
}

var scenes = {}
var current_scene: Node = null
var current_level: SCENE_LEVEL = SCENE_LEVEL.NONE

func _ready():
	# Pre-instantiate all scenes
	_preload_scenes()
	
	# NOTE:
	# If ProjectSettings.get_setting("application/run/main_scene") is changed to a different scene,
	# we need to update current_level accordingly.
	current_scene = get_tree().current_scene
	if current_scene:
		current_level = SCENE_LEVEL.MAIN_MENU

func _preload_scenes():
	for scene_level in scene_paths:
		scenes[scene_level] = load(scene_paths[scene_level]).instantiate()

func load_scene(scene_level: SCENE_LEVEL):
	call_deferred("_deferred_load_scene", scene_level)

func _deferred_load_scene(scene_level: SCENE_LEVEL):
	if scene_level == current_level:
		return
	
	# Remove current scene from tree
	if current_scene:
		get_tree().root.remove_child(current_scene)
	
	# Add the pre-instantiated scene
	current_scene = scenes[scene_level]
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	current_level = scene_level

func reload_current_scene():
	call_deferred("_deferred_reload_scene", current_level)

func _deferred_reload_scene(scene_level: SCENE_LEVEL):	
	# Remove current scene from tree
	if current_scene:
		get_tree().root.remove_child(current_scene)
		current_scene.queue_free()

	# Re-instantiate the scene using the path mapping
	if scene_level in scene_paths:
		scenes[scene_level] = load(scene_paths[scene_level]).instantiate()
		current_scene = scenes[scene_level]
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
	else:
		print("Error: Scene level ", scene_level, " not found in scene_paths")

func get_current_scene() -> Node:
	return current_scene

func get_current_level() -> SCENE_LEVEL:
	return current_level
