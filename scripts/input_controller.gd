class_name PhysicalInputManager extends Node

@export_group("Required References")
@export var rb: RigidBody2D
@export var spring_joint: DampedSpringJoint2D

@export_group("Physics Configuration")
@export var float_amplitude: float = 6.0
@export var float_frequency: float = 2.5
@export var float_speed: float = 100.0
@export var impulse_strength: float = 200.0
@export var spring_stiffness: float = 1000.0
@export var spring_damping: float = 8.0
@export var spring_length: int = 1

var is_dragging: bool = false
var is_in_word_area: bool = false
var initial_position: Vector2
var target_position: Vector2
var drag_offset: Vector2
var time_passed: float = 0

var mouse_body: StaticBody2D

func _ready():
	rb.gravity_scale = 0.0
	rb.input_pickable = true
	
	spring_joint.stiffness = spring_stiffness
	spring_joint.damping = spring_damping
	spring_joint.length = spring_length
	spring_joint.node_b = NodePath()
	
	mouse_body = get_tree().get_nodes_in_group("mouse_body")[0]

func setup_letter(start_pos: Vector2, randomness: bool = true, radius: float = 1.0):
	
	if !randomness:
		rb.global_position = start_pos
		return
	
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var random_distance = sqrt(randf()) * radius

	var spawn_position = start_pos + (random_direction * random_distance)

	rb.global_position = spawn_position
	initial_position = rb.global_position

	var random_impulse_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	rb.apply_central_impulse(random_impulse_direction * impulse_strength)

func _process(delta):
	time_passed += delta
	if is_dragging and mouse_body:
		
		if rb.linear_velocity.length() > 100:
			rb.linear_velocity *= 0.9
	
	if is_dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_stop_dragging()
	
	# Check if letter is out of viewport bounds and teleport to center
	_check_bounds()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_dragging()
	# Add touch support
	elif event is InputEventScreenTouch and event.pressed:
		_start_dragging()

func _start_dragging():
	is_dragging = true
	
	# Update mouse_body position immediately to current touch/click position
	if mouse_body:
		mouse_body.global_position = mouse_body.get_global_mouse_position()
	
	spring_joint.node_b = mouse_body.get_path()
	
	rb.gravity_scale = 0.0
	rb.linear_damp = 5.0
	
	rb.dragged.emit(rb)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _stop_dragging():
	is_dragging = false
	
	spring_joint.node_b = NodePath()
	
	rb.gravity_scale = 0.0
	rb.linear_damp = 1.0
	
	rb.released.emit(rb)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _check_bounds():
	var viewport_size = get_viewport().get_visible_rect().size
	var pos = rb.global_position
	var margin = 50.0  # Small margin to avoid edge cases
	
	# Check if letter is out of bounds
	if pos.x < -margin or pos.x > viewport_size.x + margin or \
	   pos.y < -margin or pos.y > viewport_size.y + margin:
		# Teleport to center with randomness
		var center = viewport_size / 2.0
		var random_offset = Vector2(randf_range(-250, 250), randf_range(-250, 250))
		rb.global_position = center + random_offset
		rb.linear_velocity = Vector2.ZERO
		rb.angular_velocity = 0.0
