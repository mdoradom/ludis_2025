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
	if get_tree() and !paused:
		get_tree().paused = !get_tree().paused
		paused = true


func _on_continuar_button_pressed() -> void:
	self.visible = false
	paused = false
	get_tree().paused = !get_tree().paused


func _on_sortir_button_pressed() -> void:
	self.visible = false
	paused = false
	get_tree().paused = !get_tree().paused
	SceneManager.load_scene(SceneManager.SCENE_LEVEL.MAIN_MENU)
