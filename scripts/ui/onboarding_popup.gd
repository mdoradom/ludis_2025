extends Popup

@onready var hover_tween: Tween

func _hover_effect(button: Control, hover_in: bool) -> void:
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	
	if hover_in:
		hover_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		hover_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
		
func _on_jugar_button_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.BUTTON_CLICK)
	UserData.is_first_playthrough = false
	UserData.save_game()
	hide()

func _on_jugar_button_mouse_entered() -> void:
	_hover_effect($JugarButton, true)
	
func _on_jugar_button_mouse_exited() -> void:
	_hover_effect($JugarButton, false)
