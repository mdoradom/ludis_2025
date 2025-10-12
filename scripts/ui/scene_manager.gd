extends Node

## SceneManager singleton for handling scene transitions.
##
## This autoload manages scene lifecycle by pre-instantiating all scenes for fast switching
## and handling proper cleanup during transitions. Supports both scene switching and reloading.
##
## @tutorial(Godot Docs singletons autoload): https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
## @tutorial(Godot Docs change scenes manually): https://docs.godotengine.org/en/latest/tutorials/scripting/change_scenes_manually.html
## @tutorial(Godot Forum): https://forum.godotengine.org/t/what-is-the-best-way-to-handle-menu-navigation-in-gdscript-scene-layout/24711/2

## Enumeration of available scene levels in the game.
enum SCENE_LEVEL {
	NONE,			## No scene loaded
	MAIN_MENU,		## Main menu scene
	GAME,			## Game scene
	OPTIONS,		## Options menu scene
	STICKER_BOOK	## Sticker Book scene
	# ... add other scenes
}

## Mapping of scene levels to their respective .tscn file paths.
var scene_paths = {
	SCENE_LEVEL.MAIN_MENU: "res://scenes/ui/main_menu.tscn",
	SCENE_LEVEL.GAME: "res://scenes/game/main.tscn",
	SCENE_LEVEL.OPTIONS: "res://scenes/ui/options_menu.tscn",
	SCENE_LEVEL.STICKER_BOOK: "res://scenes/ui/sticker_book.tscn"
	# ... add other scene paths
}

## Dictionary storing pre-instantiated scene nodes for fast switching.
var scenes = {}

## Reference to the currently active scene node.
var current_scene: Node = null

## The current scene level being displayed.
var current_level: SCENE_LEVEL = SCENE_LEVEL.NONE

## Initializes the SceneManager by pre-loading all scenes and setting up the current scene.
func _ready():
	_preload_scenes()
	
	# NOTE:
	# If ProjectSettings.get_setting("application/run/main_scene") is changed to a different scene,
	# we need to update current_level accordingly.
	current_scene = get_tree().current_scene
	if current_scene:
		current_level = SCENE_LEVEL.MAIN_MENU

## Pre-instantiates all scenes defined in [member scene_paths] for faster scene switching.
## Called once during [method _ready] to avoid loading delays during transitions.
func _preload_scenes():
	for scene_level in scene_paths:
		scenes[scene_level] = load(scene_paths[scene_level]).instantiate()

## Switches to the specified scene level using deferred execution.
## Does nothing if the target scene is already active.
## [param scene_level]: The [enum SCENE_LEVEL] to switch to.
## [codeblock]
## # Switch to game scene
## SceneManager.load_scene(SceneManager.SCENE_LEVEL.GAME)
## [/codeblock]
func load_scene(scene_level: SCENE_LEVEL):
	call_deferred("_deferred_load_scene", scene_level)

## Internal deferred function that performs the actual scene switching.
## Removes the current scene from the tree and adds the target scene.
## [param scene_level]: The [enum SCENE_LEVEL] to switch to.
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

## Reloads the current scene by recreating it from scratch.
## Useful for resetting game state or applying changes during development.
## [codeblock]
## # Reset the current scene to initial state
## SceneManager.reload_current_scene()
## [/codeblock]
func reload_current_scene():
	call_deferred("_deferred_reload_scene", current_level)

## Internal deferred function that performs the actual scene reloading.
## Destroys the current scene instance and creates a fresh one from the .tscn file.
## [param scene_level]: The [enum SCENE_LEVEL] to reload (typically [member current_level]).
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

## Returns the currently active scene node.
## [return]: The current scene [Node], or [code]null[/code] if none is set.
func get_current_scene() -> Node:
	return current_scene

## Returns the current scene level enum value.
## [return]: The current [enum SCENE_LEVEL] value.
func get_current_level() -> SCENE_LEVEL:
	return current_level
