extends Control


@onready var version_label := %VersionLabel


# TODO: Add tooltip and extra information.

func _ready() -> void:
	# Set version label.
	version_label.text = "v: " + ProjectSettings.get(&"application/config/version")
