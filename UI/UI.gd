extends Node


# Overlays.

@onready var player_overlay := $OverlayCanvasLayer/PlayerOverlay

@onready var health_overlay := $OverlayCanvasLayer/PlayerOverlay/HealthOverlay

@onready var help_overlay := $OverlayCanvasLayer/PlayerOverlay/HelpOverlay

# Main Menu.

@onready var main_menu_base := $MenuCanvasLayer/MainMenu

# Credits Menu.

@onready var credits_menu_base := $MenuCanvasLayer/CreditsMenu

# Help Menu.

@onready var help_menu_base := $MenuCanvasLayer/HelpMenu

# Game Over Menu.

@onready var game_over_menu_base := $MenuCanvasLayer/GameOverMenu


# Virtual methods.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_menu"):
		toggle_menu()
	elif event.is_action_pressed(&"open_help"):
		toggle_help()


# Callbacks.

func _on_help_overlay_help_pressed() -> void:
	open_help()


func _on_main_menu_credits_pressed() -> void:
	open_credits()


func _on_main_menu_help_pressed() -> void:
	open_help()


func _on_main_menu_quit_pressed() -> void:
	do_quit()


func _on_main_menu_restart_pressed() -> void:
	restart_game()


func _on_credits_menu_close_pressed() -> void:
	close_credits()


func _on_help_menu_close_pressed() -> void:
	close_help()


func _on_game_over_menu_quit_pressed() -> void:
	do_quit()


func _on_game_over_menu_restart_pressed() -> void:
	restart_game()


# Helper methods.

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


func restart_game() -> void:
	# TODO: Move to game state helper.
	get_tree().reload_current_scene()
	main_menu_base.visible = false
	game_over_menu_base.visible = false
	get_tree().paused = false


func do_quit() -> void:
	# TODO: Add confirmation.
	get_tree().quit()


func update_health(lives: int) -> void:
	health_overlay.update_health(lives)


func game_over() -> void:
	game_over_menu_base.visible = true
	get_tree().paused = true
