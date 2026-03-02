extends RigidBody3D

func _on_body_entered(body: Node):
	globals._model_shatter(body, 10.0)
