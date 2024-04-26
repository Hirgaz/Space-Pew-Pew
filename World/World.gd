extends Node2D


@onready var camera := $Camera2D
@onready var version_label := %VersionLabel
@onready var world_bounds := $WorldBounds
@onready var world_bounds_shape := $WorldBounds/WorldBoundsShape


func _update_bounds() -> void:
	# TODO: Decide on logic for scene resize.
	var shape := world_bounds_shape.shape as RectangleShape2D
	shape.size = get_viewport_rect().size


func _ready() -> void:
	# Detect window size changes.
	get_window().size_changed.connect(_update_bounds)
	_update_bounds()
	
	# Set version label.
	version_label.text = "v: " + ProjectSettings.get(&"application/config/version")


func _on_world_bounds_body_exited(body: Node2D) -> void:
	if body.has_method(&"exit_map"):
		body.exit_map()
