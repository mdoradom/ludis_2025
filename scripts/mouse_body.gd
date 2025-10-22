extends StaticBody2D

var _current_position: Vector2

func _ready() -> void:
	_current_position = global_position

func _input(event: InputEvent) -> void:
	# Track both mouse motion and touch/drag events
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_current_position = event.position
	elif event is InputEventScreenTouch and event.pressed:
		_current_position = event.position

func _physics_process(delta: float) -> void:
	global_position = _current_position
