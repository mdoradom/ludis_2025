extends Node

@onready var current_theme: Theme = preload("res://default.tres")

@onready var master_slider = $BackgroundPanel/MarginContainer/VBoxContainer/VBoxContainer4/MasterSlider
@onready var music_slider = $BackgroundPanel/MarginContainer/VBoxContainer/VBoxContainer2/MusicaSlider
@onready var effects_slider = $BackgroundPanel/MarginContainer/VBoxContainer/VBoxContainer3/EfectesSlider

func _ready():
	_load_audio_settings()
	
	AudioManager.volume_changed.connect(_on_volume_changed)

func _load_audio_settings():
	master_slider.value = AudioManager.master_volume
	music_slider.value = AudioManager.music_volume
	effects_slider.value = AudioManager.effects_volume

func _on_master_slider_value_changed(value: float):
	AudioManager.set_master_volume(value)

func _on_musica_slider_value_changed(value: float):
	AudioManager.set_music_volume(value)

func _on_efectes_slider_value_changed(value: float):
	AudioManager.set_effects_volume(value)

func _on_volume_changed(bus_name: String, volume: float):
	# Optional: Add visual feedback for volume changes
	print("Volume changed: ", bus_name, " = ", volume)

func _on_close_button_pressed():
	self.visible = false


func _on_check_button_toggled(toggled_on: bool) -> void:

	if toggled_on:
		current_theme.default_font = load("res://assets/fonts/opendyslexic-0.91.12/compiled/OpenDyslexic-Regular.otf")
	else:
		current_theme.default_font = load("res://assets/fonts/varela_round/VarelaRound-Regular.ttf")
