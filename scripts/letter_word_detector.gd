extends Node2D

signal candidate_found(target)

var area: Area2D

func _ready() -> void:
	area = $MagnetAreaSensor

func _on_magnet_area_sensor_body_entered(body: Node2D) -> void:
	if body != get_parent() and body is Letter or body is WordGroup:
		emit_signal("candidate_found", body)

func _on_magnet_area_sensor_body_exited(body: Node2D) -> void:
	emit_signal("candidate_found", null)

func _on_letter_letter_dragged(letter: Variant) -> void:
	area.visible = true
	area.monitoring = true

func _on_letter_letter_released(letter: Variant) -> void:
	area.visible = false
	area.monitoring = false
