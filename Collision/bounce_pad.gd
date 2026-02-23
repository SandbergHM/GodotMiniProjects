extends Area3D

@export var bounce_strength : float = 5.0

#Launch player upward
func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
		if body.is_in_group("Player"):
			body.apply_impulse(Vector3.UP * bounce_strength)
