extends CanvasLayer

var paused: bool = false

func _on_opcions_button_pressed() -> void:
	self.visible = false
	$OptionsUI.visible = true


func _on_options_ui_visibility_changed() -> void:
	if $OptionsUI.visible:
		self.visible = false
	else:
		self.visible = true


func _on_visibility_changed() -> void:
	# Check if the node is in the tree before accessing get_tree()
	if is_inside_tree() and visible and !paused:
		get_tree().paused = true
		paused = true


func _on_continuar_button_pressed() -> void:
	self.visible = false
	paused = false
	get_tree().paused = false


func _on_sortir_button_pressed() -> void:
	self.visible = false
	paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
