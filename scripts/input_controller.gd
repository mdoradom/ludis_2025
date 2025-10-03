class_name LetterInputManager extends Node

@export_group("Required References")
@export var letter_rb: RigidBody2D
@export var spring_joint: DampedSpringJoint2D

@export_group("Physics Configuration")
@export var float_amplitude: float = 6.0
@export var float_frequency: float = 2.5
@export var float_speed: float = 100.0
@export var impulse_strength: float = 200.0
@export var spring_stiffness: float = 1000.0
@export var spring_damping: float = 8.0
@export var spring_length: int = 1

@export var text_label: Label

var is_floating: bool = false
var is_dragging: bool = false
var is_in_word_area: bool = false
var initial_position: Vector2
var target_position: Vector2
var drag_offset: Vector2
var time_passed: float = 0

var mouse_body: StaticBody2D

func _ready():
	letter_rb.gravity_scale = 0.0
	letter_rb.input_pickable = true
	
	spring_joint.stiffness = spring_stiffness
	spring_joint.damping = spring_damping
	spring_joint.length = spring_length
	spring_joint.node_b = NodePath()
	
	mouse_body = get_tree().current_scene.get_node("MouseBody")

func setup(start_pos: Vector2):
	letter_rb.global_position = start_pos
	initial_position = letter_rb.global_position
	
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	letter_rb.apply_central_impulse(random_direction * impulse_strength)
	
	is_floating = true

func _process(delta):
	time_passed += delta
	if is_dragging and mouse_body:
		
		if letter_rb.linear_velocity.length() > 100:
			letter_rb.linear_velocity *= 0.9
	
	if is_dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_stop_dragging()

func _on_letter_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_dragging()

func _start_dragging():
	is_dragging = true
	
	spring_joint.node_b = mouse_body.get_path()
	
	letter_rb.gravity_scale = 0.0
	letter_rb.linear_damp = 5.0
	
	#emit_signal("letter_dragged", letter_rb)
	letter_rb.letter_dragged.emit(letter_rb)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _stop_dragging():
	is_dragging = false
	
	spring_joint.node_b = NodePath()
	
	letter_rb.gravity_scale = 0.0
	letter_rb.linear_damp = 1.0
	
	#emit_signal("letter_released", letter_rb)
	letter_rb.letter_released.emit(letter_rb)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
