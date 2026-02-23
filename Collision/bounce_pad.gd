extends RigidBody3D

@export var bounce_strength : float = 2000.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):

		apply_impulse(Vector3.ZERO, Vector3.UP * bounce_strength)
