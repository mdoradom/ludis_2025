extends Control
class_name Sticker

signal sticker_picked(sticker: Sticker)

@export var texture_size: float = 1.0
@export var drag_lerp_speed: float = 20.0

@onready var sprite_material: ShaderMaterial = $Texture.material

var object_data: BreakableObjectData
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

func spawn(object_data: BreakableObjectData):
	self.object_data = object_data
	name = object_data.item_name
	$Texture.texture = object_data.sprite
	$Texture.scale = Vector2(texture_size, texture_size)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
				sticker_picked.emit(self)
				_on_dragged(self)
			else:
				is_dragging = false
				_on_released(self)

func _process(delta):
	if is_dragging:
		target_position = get_global_mouse_position() - drag_offset
		global_position = global_position.lerp(target_position, drag_lerp_speed * delta)

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(sprite_material, "shader_parameter/outline_amount", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(sprite_material, "shader_parameter/outline_amount", 0.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _on_dragged(object: Variant) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_material, "shader_parameter/shadow_amount", 1.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_released(object: Variant) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_material, "shader_parameter/shadow_amount", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
