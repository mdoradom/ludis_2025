extends Control

func _process(delta):
	
	if get_parent().is_hovered:
		scale = Vector2(1.25, 1.25)
	
	if get_parent().is_dragging:
		scale = Vector2(1.5, 1.5) 

	if not get_parent().is_hovered:
		scale = Vector2(1.0, 1.0)
