extends RigidBody3D

##player right-left movement speed
@export var move_speed : float = 3
##player jump height
@export var jump_force : float = 1

@onready var ray = $GroundDetector

func is_on_floor() -> bool:
	return ray.is_colliding()

func _process(delta):
	#Restart if player falls too low
	if position.y < -20:
		get_tree().reload_current_scene()
		
	print(is_on_floor())


func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_A):
		apply_force(Vector3.LEFT * move_speed)
	if Input.is_physical_key_pressed(KEY_D):
		apply_force(Vector3.RIGHT * move_speed)
	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		apply_impulse(Vector3.UP * jump_force)
		



#Restart if player collides with tree
func _on_body_entered(body: Node):
	if body.is_in_group("Tree"):
		get_tree().reload_current_scene()
