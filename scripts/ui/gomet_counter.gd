extends HBoxContainer

var level: Level

func _ready() -> void:
	level = get_node("../..")
	level.sticker_unlocked.connect(_on_sticker_unlocked)
	$GometLabel.text = str(UserData.total_gomets)


func _on_sticker_unlocked() -> void:
	UserData.total_gomets += UserData.new_gomets_earned
	$GometLabel.text = str(UserData.total_gomets)
