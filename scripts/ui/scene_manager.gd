extends Node

enum SCENE_LEVEL {
	NONE,
	MAIN_MENU,
	GAME,
	# ... add other scenes
}

var scenes = {
	SCENE_LEVEL.MAIN_MENU : preload("res://scenes/ui/main_menu.tscn").instantiate(),
	SCENE_LEVEL.GAME : preload("res://scenes/game/main.tscn").instantiate(),
	# ... add other scenes
}

var current_scene: Node = null
var current_level: SCENE_LEVEL = SCENE_LEVEL.NONE

func _ready():
	# IMPORTANT:
	# If ProjectSettings.get_setting("application/run/main_scene") is changed to a different scene,
	# we need to update current_level accordingly.
	current_scene = get_tree().current_scene
	if current_scene:
		current_level = SCENE_LEVEL.MAIN_MENU

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
