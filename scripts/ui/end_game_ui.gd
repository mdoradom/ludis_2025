extends CanvasLayer

func _on_level_game_finished() -> void:
	get_tree().paused = true
	visible = true

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.reload_current_scene()
