extends Node

signal volume_changed(bus_name: String, volume: float)

# Audio buses
const MASTER_BUS = 0
const EFFECTS_BUS = 1 
const MUSIC_BUS = 2

# Default volumes (0.0 to 1.0)
var master_volume: float = 0.8
var effects_volume: float = 0.7
var music_volume: float = 0.6

# Audio players
var music_player: AudioStreamPlayer

# Settings file path
const AUDIO_SETTINGS_PATH = "user://audio_settings.cfg"

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	_load_audio_settings()
	_apply_volumes()

func set_master_volume(volume: float):
	_set_volume(MASTER_BUS, "Master", volume, "master_volume")

func set_effects_volume(volume: float):
	_set_volume(EFFECTS_BUS, "Effects", volume, "effects_volume")

func set_music_volume(volume: float):
	_set_volume(MUSIC_BUS, "Music", volume, "music_volume")

func _set_volume(bus_index: int, bus_name: String, volume: float, property_name: String):
	volume = clamp(volume, 0.0, 1.0)
	set(property_name, volume)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))
	volume_changed.emit(bus_name, volume)
	_save_audio_settings()

func play_sound_effect(sound: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0):
	if not sound:
		return
	
	var player = AudioStreamPlayer.new()
	player.stream = sound
	player.bus = "Effects"
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(music: AudioStream, fade_in: bool = true):
	if music_player.stream == music and music_player.playing:
		return
	
	if music_player.playing and fade_in:
		var tween = create_tween()
		tween.tween_method(_set_music_volume_db, 0.0, -60.0, 0.5)
		tween.tween_callback(func(): _start_music(music, fade_in))
	else:
		_start_music(music, fade_in)

func _start_music(music: AudioStream, fade_in: bool):
	music_player.stream = music
	music_player.volume_db = -60.0 if fade_in else 0.0
	music_player.play()
	
	if fade_in:
		var tween = create_tween()
		tween.tween_method(_set_music_volume_db, -60.0, 0.0, 0.5)

func _set_music_volume_db(volume_db: float):
	music_player.volume_db = volume_db

func stop_music(fade_out: bool = true):
	if not music_player.playing:
		return
	
	if fade_out:
		var tween = create_tween()
		tween.tween_method(_set_music_volume_db, 0.0, -60.0, 0.5)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()

func _apply_volumes():
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(EFFECTS_BUS, linear_to_db(effects_volume))
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))

func _save_audio_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "effects_volume", effects_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.save(AUDIO_SETTINGS_PATH)

func _load_audio_settings():
	var config = ConfigFile.new()
	if config.load(AUDIO_SETTINGS_PATH) == OK:
		master_volume = config.get_value("audio", "master_volume", master_volume)
		effects_volume = config.get_value("audio", "effects_volume", effects_volume)
		music_volume = config.get_value("audio", "music_volume", music_volume)
