extends Control


func _on_button_pressed() -> void:
    AudioManager.play_sfx(AudioManager.SFX.BUTTON_CLICK)
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
