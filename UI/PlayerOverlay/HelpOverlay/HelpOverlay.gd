extends Control


signal help_pressed()


@onready var help_button := %HelpButton


func _ready() -> void:
	# TODO: Workaround to ensure tooltip is correctly extracted by POT generator.
	help_button.tooltip_text = "Open the instructions and controls menu"


func _on_help_button_pressed() -> void:
	help_pressed.emit()
