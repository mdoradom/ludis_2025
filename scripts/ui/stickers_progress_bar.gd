extends ProgressBar

var level: Level

func _ready() -> void:
	level = get_node("../..")
	level.sticker_unlocked.connect(_on_sticker_unlocked)
	$".".max_value = 22 # TODO fix this to not be hardcoded --> level.starting_dictionary.get_size() but this is beeing loaded before we load the dictionary
	$".".value = UserData.unlocked_stickers.get_size()

func _on_sticker_unlocked() -> void:
	# Update progress bar when a sticker is unlocked
	value = UserData.unlocked_stickers.get_size()
