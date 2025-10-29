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
	finish_game()
	get_tree().reload_current_scene()

func _on_go_to_main_menu_button_pressed() -> void:
	finish_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func finish_game():
	UserData.new_gomets_earned = 0
	
	get_tree().paused = false
