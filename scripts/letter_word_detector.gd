extends Node2D

signal candidate_found(target)

@export var search_debug_lines: bool = false

var area: Area2D
var search_candidates: bool
var current_candidate: Node2D = null

var debug_candidates: Array = []

func _ready() -> void:
	area = $MagnetAreaSensor

func _physics_process(delta: float) -> void:
	if search_candidates:
		current_candidate = look_for_candidates()
		emit_signal("candidate_found", current_candidate)
	else:
		debug_candidates.clear()
		current_candidate = null
	
	if search_debug_lines:
		queue_redraw()

func look_for_candidates():
	var potential_candidates = area.get_overlapping_bodies()
	if search_debug_lines == true:
		debug_candidates = potential_candidates.duplicate() # store for debug drawing

	var less_dist: float = INF
	var candidate = null
	for pc in potential_candidates:
		if pc != get_parent():
			var dist = global_position.distance_to(pc.global_position)
			if dist < less_dist:
				less_dist = dist
				candidate = pc
	return candidate

func _on_magnet_area_sensor_body_entered(body: Node2D) -> void:
	if body != get_parent() and (body is Letter or body is WordGroup):
		pass

func _on_magnet_area_sensor_body_exited(body: Node2D) -> void:
	pass

func _on_letter_letter_dragged(letter: Variant) -> void:
	area.visible = true
	area.monitoring = true
	search_candidates = true

func _on_letter_letter_released(letter: Variant) -> void:
	area.visible = false
	area.monitoring = false
	search_candidates = false
	
func _draw() -> void:
	if not search_candidates:
		return
	
	# Draw lines to all current candidates
	for c in debug_candidates:
		if not c or not c.is_inside_tree():
			continue
		var color = Color(0, 0.5, 1, 0.6) # blue for all candidates
		if c == current_candidate:
			color = Color(1, 0.3, 0.2, 1.0) # red for selected candidate
		draw_line(Vector2.ZERO, to_local(c.global_position), color, 2.0)
	
	# Optionally draw a small circle at self
	draw_circle(Vector2.ZERO, 4, Color(1, 1, 1, 0.6))
