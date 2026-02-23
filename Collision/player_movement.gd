extends RigidBody3D

##player right-left movement speed
@export var move_speed : float = 3

# Called 60 times per second. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_A):
		apply_force(Vector3.LEFT * move_speed)
	if Input.is_physical_key_pressed(KEY_D):
		apply_force(Vector3.RIGHT * move_speed)
		
	if position.y < -20:
		get_tree().reload_current_scene()

func _on_body_entered(body: Node):
	if body.is_in_group("Tree"):
		get_tree().reload_current_scene()
