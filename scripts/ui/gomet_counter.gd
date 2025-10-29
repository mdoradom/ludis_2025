extends HBoxContainer

var level: Level

func _ready() -> void:
	level = get_tree().current_scene as Level
	if level and level.has_signal("sticker_unlocked"):
		level.sticker_unlocked.connect(_on_sticker_unlocked)
	$GometLabel.text = str(UserData.total_gomets)

func _on_sticker_unlocked() -> void:
	$GometLabel.text = str(UserData.total_gomets)
