extends Area2D

signal letter_dragged(letter)
signal letter_released(letter)
signal letter_clicked(letter)

# Floating / motion properties
@export var float_amplitude: float = 6.0
@export var float_frequency: float = 2.5
@export var float_speed: float = 30.0

var value: String = ""
var is_floating: bool = false
var is_dragging: bool = false
var is_in_word_area: bool = false
var initial_position: Vector2
var target_position: Vector2
var drag_offset: Vector2
var time_passed: float = 0
var float_direction: Vector2

func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func setup(letter_char: String, start_pos: Vector2):
	value = letter_char
	position = start_pos
	initial_position = position
	
	$Label.text = value
	float_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	is_floating = true

func _process(delta):
	time_passed += delta
	
	if is_dragging:
		position = get_global_mouse_position() + drag_offset
	elif is_floating:
		# Apply floating motion using local float properties
		var float_offset = float_amplitude * sin(time_passed * float_frequency)
		position += float_direction * float_speed * delta
		position += Vector2(0, float_offset * delta)
		
		# Bounce off screen edges
		var viewport_size = get_viewport_rect().size
		if position.x < 0 or position.x > viewport_size.x:
			float_direction.x *= -1
		if position.y < 0 or position.y > viewport_size.y:
			float_direction.y *= -1

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_floating = false
			is_dragging = true
			drag_offset = position - get_global_mouse_position()
			emit_signal("letter_dragged", self)
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			is_dragging = false
			emit_signal("letter_released", self)
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_mouse_entered():
	if not is_dragging:
		# Visual feedback - scale up slightly
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	if not is_dragging:
		scale = Vector2(1.0, 1.0)

func stop_floating():
	is_floating = false
