extends Panel

func _on_mouse_entered() -> void:
	modulate.a = 0.7

func _on_word_group_dragged(object: Variant) -> void:
	modulate.a = 0.4


func _on_word_group_released(object: Variant) -> void:
		modulate.a = 1.0
