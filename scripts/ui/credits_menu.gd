extends Control


func _on_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON_CLICK)
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.MAIN_MENU)
