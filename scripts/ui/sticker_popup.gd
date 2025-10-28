extends Popup

@export var display_duration: float = 3.0

@onready var sticker_texture: TextureRect = $MarginContainer/BackgroundPanel/MarginContainer/VBoxContainer/StickerContainer/StickerTexture
@onready var sticker_name_label: Label = $MarginContainer/BackgroundPanel/MarginContainer/VBoxContainer/StickerName
@onready var unlock_message_label: Label = $MarginContainer/BackgroundPanel/MarginContainer/VBoxContainer/UnlockMessage

func show_sticker_unlock(object_data: BreakableObjectData) -> void:
	if not object_data:
		push_error("StickerPopup: Cannot show popup - object_data is null")
		return
	
	_setup_popup_content(object_data)
	
	AudioManager.play_sfx(AudioManager.SFX.STICK_STICKER) # TODO change to correct sound effect
	
	popup_centered()
	_schedule_auto_hide()

func _setup_popup_content(object_data: BreakableObjectData) -> void:
	if object_data.sprite:
		sticker_texture.texture = object_data.sprite
	else:
		sticker_texture.texture = preload("res://icon.svg")
	
	sticker_name_label.text = object_data.item_name.to_upper()

func _schedule_auto_hide() -> void:
	var timer = Timer.new()
	timer.wait_time = display_duration
	timer.one_shot = true
	timer.timeout.connect(_hide_popup)
	add_child(timer)
	timer.start()

func _hide_popup() -> void:
	hide()
	queue_free()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_hide_popup()

static func create_and_show(object_data: BreakableObjectData, parent_node: Node = null) -> void:
	var popup_scene = preload("res://scenes/ui/sticker_popup.tscn")
	var popup_instance = popup_scene.instantiate()
	
	var target_parent = parent_node if parent_node else SceneManager.current_scene
	target_parent.add_child(popup_instance)
	
	popup_instance.show_sticker_unlock(object_data)
