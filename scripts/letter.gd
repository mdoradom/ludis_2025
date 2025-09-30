extends RigidBody2D

signal letter_dragged(letter)
signal letter_released(letter)
signal letter_clicked(letter)

@export var float_amplitude: float = 6.0
@export var float_frequency: float = 2.5
@export var float_speed: float = 100.0
@export var impulse_strength: float = 200.0
@export var spring_stiffness: float = 50.0
@export var spring_damping: float = 2.0

var value: String = ""
var is_floating: bool = false
var is_dragging: bool = false
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
	
	$Label.text = value
	
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	apply_central_impulse(random_direction * impulse_strength)
	
	is_floating = true

func _process(delta):
	time_passed += delta
	if is_dragging and mouse_body:
		mouse_body.global_position = get_global_mouse_position() + drag_offset

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_dragging()
		else:
			_stop_dragging()

func _start_dragging():
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	
	mouse_body.global_position = get_global_mouse_position() + drag_offset
	spring_joint.node_b = mouse_body.get_path()
	
	gravity_scale = 0.1
	
	emit_signal("letter_dragged", self)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _stop_dragging():
	is_dragging = false
	
	spring_joint.node_b = NodePath()
	
	gravity_scale = 0.0
	
	emit_signal("letter_released", self)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_mouse_entered():
	if not is_dragging:
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	if not is_dragging:
		scale = Vector2(1.0, 1.0)

func _exit_tree():
	if mouse_body and is_instance_valid(mouse_body):
		mouse_body.queue_free()
