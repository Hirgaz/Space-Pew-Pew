extends Control


signal help_pressed()


@onready var help_button := %HelpButton


func _ready() -> void:
	# TODO: Remove workaround for POT extraction.
	help_button.text = "?" # NO_TRANSLATE
	help_button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED


func _on_help_button_pressed() -> void:
	help_pressed.emit()
