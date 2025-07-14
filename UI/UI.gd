extends Node


@onready var version_label := %VersionLabel

@onready var music_display := %MusicVolumeDisplay
@onready var music_slider := %MusicVolumeSlider
@onready var voice_display := %VoiceVolumeDisplay
@onready var voice_slider := %VoiceVolumeSlider
@onready var effects_display := %EffectsVolumeDisplay
@onready var effects_slider := %EffectsVolumeSlider
@onready var ui_display := %UIVolumeDisplay
@onready var ui_slider := %UIVolumeSlider
@onready var main_display := %MainVolumeDisplay
@onready var main_slider := %MainVolumeSlider

@onready var main_menu_base := $MenuCanvasLayer/MainMenu
@onready var credits_menu_base := $MenuCanvasLayer/CreditsMenu
@onready var game_over_menu_base := $MenuCanvasLayer/GameOverMenu

@onready var quit_button_main := %QuitButtonMain
@onready var quit_button_game_over := %QuitButtonGameOver

@onready var player_overlay := $OverlayCanvasLayer/PlayerOverlay
@onready var health_counter := %HealthCounter

var music_bus_index: int
var voice_bus_index: int
var effects_bus_index: int
var ui_bus_index: int


func _ready() -> void:
	# Disable quit button on Web.
	if OS.has_feature("web"):
		quit_button_main.visible = false
		quit_button_game_over.visible = false

	# Set version label.
	version_label.text = "v: " + ProjectSettings.get(&"application/config/version")

	# Get bus indices.
	music_bus_index = AudioServer.get_bus_index(&"Music")
	voice_bus_index = AudioServer.get_bus_index(&"Voice")
	effects_bus_index = AudioServer.get_bus_index(&"Effects")
	ui_bus_index = AudioServer.get_bus_index(&"UI")

	# Update volumes.
	var music_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index)) * 100.0
	music_slider.set_value_no_signal(music_volume)
	music_display.text = "%d%%" % music_volume

	var voice_volume = db_to_linear(AudioServer.get_bus_volume_db(voice_bus_index)) * 100.0
	voice_slider.set_value_no_signal(voice_volume)
	voice_display.text = "%d%%" % voice_volume

	var effects_volume = db_to_linear(AudioServer.get_bus_volume_db(effects_bus_index)) * 100.0
	effects_slider.set_value_no_signal(effects_volume)
	effects_display.text = "%d%%" % effects_volume

	var ui_volume = db_to_linear(AudioServer.get_bus_volume_db(ui_bus_index)) * 100.0
	ui_slider.set_value_no_signal(ui_volume)
	ui_display.text = "%d%%" % ui_volume

	var main_volume = db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	main_slider.set_value_no_signal(main_volume)
	main_display.text = "%d%%" % main_volume

	# Initialize Godot license label.
	%GodotLicenseLabel.text = Engine.get_license_text()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu"):
		toggle_menu()


func toggle_menu() -> void:
	if game_over_menu_base.visible:
		return
	if credits_menu_base.visible:
		credits_menu_base.visible = false
	elif main_menu_base.visible:
		main_menu_base.visible = false
		get_tree().paused = false
	else:
		main_menu_base.visible = true
		get_tree().paused = true


func open_credits() -> void:
	credits_menu_base.visible = true


func close_credits() -> void:
	credits_menu_base.visible = false


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value / 100.0))
	music_display.text = "%d%%" % value

func _on_voice_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(voice_bus_index, linear_to_db(value / 100.0))
	voice_display.text = "%d%%" % value

func _on_effects_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(effects_bus_index, linear_to_db(value / 100.0))
	effects_display.text = "%d%%" % value

func _on_ui_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(ui_bus_index, linear_to_db(value / 100.0))
	ui_display.text = "%d%%" % value

func _on_main_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))
	main_display.text = "%d%%" % value


func _on_credits_button_pressed() -> void:
	open_credits()


func _on_close_button_pressed() -> void:
	close_credits()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func update_health(lives: int) -> void:
	health_counter.text = "%dx" % lives


func game_over() -> void:
	game_over_menu_base.visible = true
	get_tree().paused = true
