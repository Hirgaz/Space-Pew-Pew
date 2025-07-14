extends Node


class ControlItem:
	var name: String
	var tooltip: String
	var action: StringName

	func _init(new_name: String, new_tooltip: String, new_action: StringName) -> void:
		name = new_name
		tooltip = new_tooltip
		action = new_action


class ControlGroup:
	var name: String
	var tooltip: String
	var items: Array[ControlItem]

	func _init(new_name: String, new_tooltip: String, new_items: Array) -> void:
		name = new_name
		tooltip = new_tooltip
		items.assign(new_items)


var CONTROL_ITEMS = [
	ControlGroup.new("General", "General actions", [
			ControlItem.new("Open Menu", "Open the main menu", &"open_menu"),
			ControlItem.new("Open Help", "Open the help menu", &"open_help"),
		]),
	ControlGroup.new("Movement", "Movement actions", [
			ControlItem.new("Turn Left/Counter Clockwise", "Rotate the ship Left/Counter clockwise", &"turn_left"),
			ControlItem.new("Turn Right/Clockwise", "Rotate the ship Right/Clockwise", &"turn_right"),
			ControlItem.new("Move Forward/Accelerate", "Increase the ship speed", &"move_forward"),
			ControlItem.new("Move Back/Decelerate", "Decrease the ship speed, or reverse", &"move_back"),
		]),
	ControlGroup.new("Actions", "Ship actions", [
			ControlItem.new("Shoot", "Fire weapons", &"shoot"),
			ControlItem.new("Shield", "Enable the shields", &"shield"),
		]),
]

# Background.

@onready var version_label := %VersionLabel

# Overlays.

@onready var player_overlay := $OverlayCanvasLayer/PlayerOverlay
@onready var health_counter := %HealthCounter

# Main Menu.

@onready var main_menu_base := $MenuCanvasLayer/MainMenu

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

@onready var quit_button_main := %QuitButtonMain

# Credits Menu.

@onready var credits_menu_base := $MenuCanvasLayer/CreditsMenu

@onready var godot_license_label := %GodotLicenseLabel

# Help Menu.

@onready var help_menu_base := $MenuCanvasLayer/HelpMenu

@onready var controls_tree : Tree = %ControlsTree

# Game Over Menu.

@onready var game_over_menu_base := $MenuCanvasLayer/GameOverMenu

@onready var quit_button_game_over := %QuitButtonGameOver


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

	# Initialize Godot license label.
	godot_license_label.text = Engine.get_license_text()

	_fill_controls()



func _controls_add_group_item(group: ControlGroup, parent: TreeItem) -> TreeItem:
	var new_item := parent.create_child()
	new_item.set_text(0, group.name)
	new_item.set_tooltip_text(0, group.tooltip)
	new_item.set_selectable(0, false)
	new_item.set_text(1, "Primary")
	new_item.set_selectable(1, false)
	new_item.set_text(2, "Secondary")
	new_item.set_selectable(2, false)

	return new_item


func _controls_add_control_item(item: ControlItem, parent: TreeItem) -> TreeItem:
	var new_item := parent.create_child()
	new_item.set_text(0, item.name)
	new_item.set_tooltip_text(0, item.tooltip)
	new_item.set_selectable(0, false)
	new_item.set_selectable(1, false)
	new_item.set_selectable(2, false)
	var action_events := InputMap.action_get_events(item.action)

	if action_events.size() >= 1:
		var key_event := action_events[0] as InputEventKey
		if key_event:
			new_item.set_text(1, key_event.as_text_physical_keycode())
			new_item.set_tooltip_text(1, key_event.as_text())

	if action_events.size() >= 2:
		var key_event := action_events[1] as InputEventKey
		if key_event:
			new_item.set_text(2, key_event.as_text_physical_keycode())
			new_item.set_tooltip_text(2, key_event.as_text())

	return new_item


func _fill_controls() -> void:
	var root_node := controls_tree.create_item()

	for group : ControlGroup in CONTROL_ITEMS:
		var group_item := _controls_add_group_item(group, root_node)

		for item : ControlItem in group.items:
			_controls_add_control_item(item, group_item)



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_menu"):
		toggle_menu()
	elif event.is_action_pressed(&"open_help"):
		toggle_help()


func toggle_menu() -> void:
	if game_over_menu_base.visible:
		return
	if credits_menu_base.visible:
		close_credits()
	elif help_menu_base.visible:
		close_help()
	elif main_menu_base.visible:
		main_menu_base.visible = false
		get_tree().paused = false
	else:
		main_menu_base.visible = true
		get_tree().paused = true


func toggle_help() -> void:
	if help_menu_base.visible:
		close_help()
	else:
		open_help()


func open_credits() -> void:
	credits_menu_base.visible = true


func close_credits() -> void:
	credits_menu_base.visible = false


func open_help() -> void:
	if not main_menu_base.visible:
		get_tree().paused = true
	help_menu_base.visible = true


func close_help() -> void:
	if not main_menu_base.visible:
		get_tree().paused = false
	help_menu_base.visible = false


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


func _on_credits_button_pressed() -> void:
	open_credits()


func _on_help_button_pressed() -> void:
	open_help()


func _on_close_credits_button_pressed() -> void:
	close_credits()


func _on_close_help_button_pressed() -> void:
	close_help()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func update_health(lives: int) -> void:
	health_counter.text = "%dx" % lives


func game_over() -> void:
	game_over_menu_base.visible = true
	get_tree().paused = true
