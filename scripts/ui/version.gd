extends Label

func _ready():
	text = "ver " + str(ProjectSettings.get_setting("application/config/version"))
