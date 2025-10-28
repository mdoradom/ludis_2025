class_name StickerList
extends Control

@export var sticker_factory: StickerFactory

var is_dragging: bool = false
var drag_start_pos: Vector2
var start_anchor: float

func _ready() -> void:
	anchor_top = 0.9
	
	spawn_stickers()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			AudioManager.play_sfx_once(AudioManager.SFX.SLIDE_PLASTIC)
			is_dragging = true
			drag_start_pos = get_global_mouse_position()
			start_anchor = anchor_top
		else:
			is_dragging = false
			_snap_to_position()
	elif event is InputEventMouseMotion and is_dragging:
		_update_position()

func _update_position() -> void:
	var current_pos = get_global_mouse_position()
	var drag_delta = current_pos.y - drag_start_pos.y
	var screen_height = get_viewport().get_visible_rect().size.y
	var new_anchor = start_anchor + (drag_delta / screen_height)
	anchor_top = clamp(new_anchor, 0.2, 0.95)

func _snap_to_position() -> void:
	var target = 0.9 if anchor_top > 0.55 else 0.2
	var tween = create_tween()
	tween.tween_property(self, "anchor_top", target, 0.3)

func spawn_stickers():
	var unlocked_sticker_dict: WordDictionary = UserData.unlocked_stickers
	
	for data in unlocked_sticker_dict.get_all_objects().values():
		var sticker = sticker_factory.spawn_sticker_from_data(data, Vector2.ZERO)
		
		sticker.reparent($MarginContainer/VBoxContainer/ScrollContainer/GridContainer)
		sticker.sticker_picked.connect(_on_sticker_picked)

func _on_sticker_picked(sticker: Sticker) -> void:
	# Slide down the sticker list
	var tween = create_tween()
	tween.tween_property(self, "anchor_top", 0.95, 0.2)
	
	# Reparent sticker to viewport
	# FIXME: PLEASE DO THIS BETTER, IS ONLY FOR TESTING!
	var sticker_list = $"../SubViewportContainer/SubViewport/Stickers"
	sticker.reparent(sticker_list)
