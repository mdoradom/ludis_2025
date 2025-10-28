extends CanvasLayer

func _on_level_game_finished() -> void:
	get_tree().paused = true
	visible = true
	
	var current_dictionary = get_tree().current_scene.current_dictionary
	var dict_size: int = current_dictionary.get_size()
	$Panel/MarginContainer/VBoxContainer/StickersProgressBar.max_value = dict_size
	$Panel/MarginContainer/VBoxContainer/StickersProgressBar.value = UserData.unlocked_stickers.get_size()
	
	$Panel/MarginContainer/VBoxContainer/WinGomets.text = str(UserData.new_gomets_earned)

func _on_retry_button_pressed() -> void:
	UserData.total_gomets += UserData.new_gomets_earned
	UserData.new_gomets_earned = 0
	
	get_tree().paused = false
	SceneManager.reload_current_scene()
