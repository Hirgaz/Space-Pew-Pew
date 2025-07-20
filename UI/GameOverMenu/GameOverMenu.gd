extends Control


signal restart_pressed()
signal quit_pressed()


@onready var quit_button := %QuitButton


func _ready() -> void:
	# Disable quit button on Web.
	if OS.has_feature("web"):
		quit_button.visible = false


func _on_restart_button_pressed() -> void:
	restart_pressed.emit()


func _on_quit_button_game_pressed() -> void:
	quit_pressed.emit()
