extends Node

signal volume_changed(bus_name: String, volume: float)

enum SFX {
	# UI Sounds
	BUTTON_CLICK,	# done

	# Game Sounds
	BREAK_SOUND,	# not done
	TAP_SOUND,		# not done
	LETTER_SNAP_1,	# done
	LETTER_SNAP_2,	# done
	COMPLETE_WORD,	# done

	# Album Sounds
	SLIDE_PLASTIC,	# not done
	STICK_STICKER,	# done
}

enum MUSIC {
	MAIN_MENU,		# not done
	GAMEPLAY,		# not done
	STICKER_BOOK,	# not done
}

const MASTER_BUS = 0
const EFFECTS_BUS = 1 
const MUSIC_BUS = 2

var master_volume: float = 0.8
var effects_volume: float = 0.7
var music_volume: float = 0.6

var music_player: AudioStreamPlayer
var sound_effects: Dictionary = {}
var music_tracks: Dictionary = {}

const AUDIO_SETTINGS_PATH = "user://audio_settings.cfg"

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	_preload_sound_effects()
	_preload_music_tracks()
	_load_audio_settings()
	_apply_volumes()

func _preload_sound_effects() -> void:
	sound_effects[SFX.BUTTON_CLICK] = preload("res://assets/audio/effects/switch_006.ogg")
	sound_effects[SFX.STICK_STICKER] = preload("res://assets/audio/effects/sfx_stickerripper_foil_05.wav")
	sound_effects[SFX.LETTER_SNAP_1] = preload("res://assets/audio/effects/letter_snap_1.wav")
	sound_effects[SFX.LETTER_SNAP_2] = preload("res://assets/audio/effects/letter_snap_2.wav")
	sound_effects[SFX.COMPLETE_WORD] = preload("res://assets/audio/effects/confirmation_004.ogg")
	# Add more sound effects here as needed

func _preload_music_tracks() -> void:
	# music_tracks[MUSIC.MAIN_MENU] = preload("res://assets/audio/music/main_menu.ogg")
	# music_tracks[MUSIC.GAMEPLAY] = preload("res://assets/audio/music/gameplay.ogg")
	# Add more music tracks here as needed
	pass

func play_sfx(sfx_type: SFX, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if sfx_type in sound_effects:
		var player = AudioStreamPlayer.new()
		player.stream = sound_effects[sfx_type]
		player.bus = "Effects"
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.finished.connect(player.queue_free)
		add_child(player)
		player.play()
	else:
		push_error("Sound effect not found: " + str(sfx_type))

func play_music(music_type: MUSIC, fade_in: bool = true) -> void:
	if music_type not in music_tracks:
		push_error("Music track not found: " + str(music_type))
		return
		
	var music = music_tracks[music_type]
	if music_player.stream == music and music_player.playing:
		return
	
	if music_player.playing and fade_in:
		var tween = create_tween()
		tween.tween_method(_set_music_volume_db, 0.0, -60.0, 0.5)
		tween.tween_callback(func(): _start_music(music, fade_in))
	else:
		_start_music(music, fade_in)

func _start_music(music: AudioStream, fade_in: bool) -> void:
	music_player.stream = music
	music_player.volume_db = -60.0 if fade_in else 0.0
	music_player.play()
	
	if fade_in:
		var tween = create_tween()
		tween.tween_method(_set_music_volume_db, -60.0, 0.0, 0.5)

func _set_music_volume_db(volume_db: float) -> void:
	music_player.volume_db = volume_db

func stop_music(fade_out: bool = true) -> void:
	if not music_player.playing:
		return
	
	if fade_out:
		var tween = create_tween()
		tween.tween_method(_set_music_volume_db, 0.0, -60.0, 0.5)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()

func set_master_volume(volume: float) -> void:
	_set_volume(MASTER_BUS, "Master", volume, "master_volume")

func set_effects_volume(volume: float) -> void:
	_set_volume(EFFECTS_BUS, "Effects", volume, "effects_volume")

func set_music_volume(volume: float) -> void:
	_set_volume(MUSIC_BUS, "Music", volume, "music_volume")

func _set_volume(bus_index: int, bus_name: String, volume: float, property_name: String) -> void:
	volume = clamp(volume, 0.0, 1.0)
	set(property_name, volume)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))
	volume_changed.emit(bus_name, volume)
	_save_audio_settings()

func _apply_volumes() -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(EFFECTS_BUS, linear_to_db(effects_volume))
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))

func _save_audio_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "effects_volume", effects_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.save(AUDIO_SETTINGS_PATH)

func _load_audio_settings() -> void:
	var config = ConfigFile.new()
	if config.load(AUDIO_SETTINGS_PATH) == OK:
		master_volume = config.get_value("audio", "master_volume", master_volume)
		effects_volume = config.get_value("audio", "effects_volume", effects_volume)
		music_volume = config.get_value("audio", "music_volume", music_volume)
