extends Node2D


@onready var camera := $Camera2D
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


func _on_world_bounds_body_exited(body: Node2D) -> void:
	# Warp players and other items.
	# TODO: Decide further details.
	body.global_position = -body.global_position
