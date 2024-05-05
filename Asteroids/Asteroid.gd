extends RigidBody2D


func exit_map() -> void:
	queue_free()


func _on_detector_body_entered(body: Node2D) -> void:
	if body.has_method(&"hit_target") and body.hit_target():
		visible = false
		queue_free()
