extends Control

@export var display_duration: float = 3.0
@export var slide_duration: float = 0.5
@export var top_margin: float = 20.0
@export var side_margin: float = 20.0

@onready var sticker_texture: TextureRect = $BackgroundPanel/MarginContainer/HBoxContainer/VBoxContainer/StickerTexture
@onready var sticker_name_label: Label = $BackgroundPanel/MarginContainer/HBoxContainer/VBoxContainer/StickerName
@onready var unlock_message_label: Label = $BackgroundPanel/MarginContainer/HBoxContainer/UnlockMessage

func show_sticker_unlock(object_data: BreakableObjectData) -> void:
	if not object_data:
		push_error("StickerPopup: Cannot show popup - object_data is null")
		return
	
	_setup_popup_content(object_data)
	_animate_slide_in()
	
	AudioManager.play_sfx(AudioManager.SFX.STICK_STICKER)

func _setup_popup_content(object_data: BreakableObjectData) -> void:
	if object_data.sprite:
		sticker_texture.texture = object_data.sprite
	else:
		sticker_texture.texture = preload("res://icon.svg")
	
	sticker_name_label.text = object_data.item_name.to_upper()

func _animate_slide_in() -> void:
	# Get popup width and viewport width for positioning
	var popup_width = size.x if size.x > 0 else 300
	var viewport_width = get_viewport_rect().size.x
	
	# Start position: off-screen to the right
	position = Vector2(viewport_width, top_margin)
	
	# Create tween for animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Slide in from right to visible position
	tween.tween_property(self, "position:x", viewport_width - popup_width - side_margin, slide_duration)
	
	# Wait while visible
	tween.tween_interval(display_duration)
	
	# Slide out to the right
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", viewport_width, slide_duration * 0.8)
	
	# Clean up after animation
	tween.tween_callback(_hide_popup)

func _hide_popup() -> void:
	queue_free()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_hide_popup()

static func create_and_show(object_data: BreakableObjectData, parent_node: Node = null) -> void:
	var popup_scene = preload("res://scenes/ui/sticker_popup.tscn")
	var popup_instance = popup_scene.instantiate()
	
	var target_parent = parent_node
	if not target_parent:
		var tree = Engine.get_main_loop() as SceneTree
		if tree:
			target_parent = tree.current_scene
	
	if target_parent:
		target_parent.add_child(popup_instance)
		popup_instance.show_sticker_unlock(object_data)
	else:
		push_error("StickerPopup: Could not find a valid parent node to attach popup")
