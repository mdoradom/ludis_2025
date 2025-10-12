extends MarginContainer

func _on_play_button_pressed() -> void:
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.GAME)

func _on_options_button_pressed() -> void:
	#SceneManager.load_scene(SceneManager.SCENE_LEVEL.OPTIONS)
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
