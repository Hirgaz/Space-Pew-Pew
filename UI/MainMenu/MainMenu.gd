extends Control


signal restart_pressed()
signal help_pressed()
signal credits_pressed()
signal quit_pressed()


@onready var music_enabled := %MusicVolumeEnabled
@onready var music_display := %MusicVolumeDisplay
@onready var music_slider := %MusicVolumeSlider

@onready var voice_enabled := %VoiceVolumeEnabled
@onready var voice_display := %VoiceVolumeDisplay
@onready var voice_slider := %VoiceVolumeSlider

@onready var effects_enabled := %EffectsVolumeEnabled
@onready var effects_display := %EffectsVolumeDisplay
@onready var effects_slider := %EffectsVolumeSlider

@onready var ui_enabled := %UIVolumeEnabled
@onready var ui_display := %UIVolumeDisplay
@onready var ui_slider := %UIVolumeSlider

@onready var main_enabled := %MainVolumeEnabled
@onready var main_display := %MainVolumeDisplay
@onready var main_slider := %MainVolumeSlider

@onready var quit_button := %QuitButton


var music_bus_index: int
var voice_bus_index: int
var effects_bus_index: int
var ui_bus_index: int


func _ready() -> void:
	# Disable quit button on Web.
	if OS.has_feature("web"):
		quit_button.visible = false

	# Get bus indices.
	music_bus_index = AudioServer.get_bus_index(&"Music")
	voice_bus_index = AudioServer.get_bus_index(&"Voice")
	effects_bus_index = AudioServer.get_bus_index(&"Effects")
	ui_bus_index = AudioServer.get_bus_index(&"UI")

	# Update volumes and mute.
	music_enabled.set_pressed_no_signal(not AudioServer.is_bus_mute(music_bus_index))
	var music_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index)) * 100.0
	music_slider.set_value_no_signal(music_volume)
	music_display.text = "%d%%" % music_volume

	voice_enabled.set_pressed_no_signal(not AudioServer.is_bus_mute(voice_bus_index))
	var voice_volume = db_to_linear(AudioServer.get_bus_volume_db(voice_bus_index)) * 100.0
	voice_slider.set_value_no_signal(voice_volume)
	voice_display.text = "%d%%" % voice_volume

	effects_enabled.set_pressed_no_signal(not AudioServer.is_bus_mute(effects_bus_index))
	var effects_volume = db_to_linear(AudioServer.get_bus_volume_db(effects_bus_index)) * 100.0
	effects_slider.set_value_no_signal(effects_volume)
	effects_display.text = "%d%%" % effects_volume

	ui_enabled.set_pressed_no_signal(not AudioServer.is_bus_mute(ui_bus_index))
	var ui_volume = db_to_linear(AudioServer.get_bus_volume_db(ui_bus_index)) * 100.0
	ui_slider.set_value_no_signal(ui_volume)
	ui_display.text = "%d%%" % ui_volume

	main_enabled.set_pressed_no_signal(not AudioServer.is_bus_mute(0))
	var main_volume = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	main_slider.set_value_no_signal(main_volume)
	main_display.text = "%d%%" % main_volume


# Volume Controls.

func _on_music_volume_enabled_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(music_bus_index, not toggled_on)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value / 100.0))
	music_display.text = "%d%%" % value

func _on_voice_volume_enabled_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(voice_bus_index, not toggled_on)


func _on_voice_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(voice_bus_index, linear_to_db(value / 100.0))
	voice_display.text = "%d%%" % value


func _on_effects_volume_enabled_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(effects_bus_index, not toggled_on)


func _on_effects_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(effects_bus_index, linear_to_db(value / 100.0))
	effects_display.text = "%d%%" % value


func _on_ui_volume_enabled_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(ui_bus_index, not toggled_on)


func _on_ui_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(ui_bus_index, linear_to_db(value / 100.0))
	ui_display.text = "%d%%" % value


func _on_main_volume_enabled_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, not toggled_on)


func _on_main_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))
	main_display.text = "%d%%" % value


func _on_restart_button_pressed() -> void:
	restart_pressed.emit()


func _on_help_button_pressed() -> void:
	help_pressed.emit()


func _on_credits_button_pressed() -> void:
	credits_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_pressed.emit()
