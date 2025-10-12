class_name StickerBook
extends Control

func _on_close_button_pressed() -> void:
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.MAIN_MENU)
