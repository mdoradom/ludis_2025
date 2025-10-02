extends RigidBody2D

signal letter_dragged(letter)
signal letter_released(letter)
signal letter_clicked(letter)

@export var float_amplitude: float = 6.0
@export var float_frequency: float = 2.5
@export var float_speed: float = 100.0
@export var impulse_strength: float = 200.0
@export var spring_stiffness: float = 1000.0
@export var spring_damping: float = 8.0
@export var spring_length: int = 1

@export var text_label: Label

var value: String = ""
var is_floating: bool = false
var is_dragging: bool = false
var is_hovered: bool = false
var is_in_word_area: bool = false
var initial_position: Vector2
var target_position: Vector2
var drag_offset: Vector2
var time_passed: float = 0

var spring_joint: DampedSpringJoint2D
var mouse_body: StaticBody2D

func _ready():
	gravity_scale = 0.0
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
	spring_joint = $DampedSpringJoint2D
	spring_joint.stiffness = spring_stiffness
	spring_joint.damping = spring_damping
	spring_joint.length = spring_length
	
	_create_mouse_body()

func _create_mouse_body():
	mouse_body = StaticBody2D.new()
	mouse_body.name = "MouseBody"
	get_parent().add_child(mouse_body)
	
	spring_joint.node_b = NodePath()

func setup(letter_char: String, start_pos: Vector2):
	value = letter_char
	global_position = start_pos
	initial_position = global_position
	
	text_label.text = value
	
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	apply_central_impulse(random_direction * impulse_strength)
	
	is_floating = true

func _process(delta):
	time_passed += delta
	if is_dragging and mouse_body:
		mouse_body.global_position = get_global_mouse_position()
		
		if linear_velocity.length() > 100:
			linear_velocity *= 0.9
	
	if is_dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_stop_dragging()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_dragging()

func _start_dragging():
	is_dragging = true
	
	mouse_body.global_position = get_global_mouse_position()
	spring_joint.node_b = mouse_body.get_path()
	
	gravity_scale = 0.0
	linear_damp = 5.0
	
	emit_signal("letter_dragged", self)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _stop_dragging():
	is_dragging = false
	
	spring_joint.node_b = NodePath()
	
	gravity_scale = 0.0
	linear_damp = 1.0
	
	emit_signal("letter_released", self)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false

func _exit_tree():
	if mouse_body and is_instance_valid(mouse_body):
		mouse_body.queue_free()
