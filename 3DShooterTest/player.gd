extends CharacterBody3D

## Character movement speed
@export var movement_speed : float = 10.0
## Character sprint speed
@export var sprint_speed : float = 5.0
## Maximum falling speed, used to prevent the player from falling too fast and breaking the game physics
@export var terminal_velocity : float = -50.0
## Player jump height
@export var jump_height : float = 5.0
## Gravity acceleration, used to pull the player down when in the air
@export var fall_acceleration = 9.8

## Velocity of the player, used for movement and gravity
var target_velocity = Vector3.ZERO
## Speed boost when the player is moving, used for sprinting or dashing mechanics
var movement_boost_speed : float = 0
## Mouse movement
var mouse_movement = Input.get_last_mouse_velocity()
## Player rotation speed
var rotation_speed: float = 0.005


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	up_direction = Vector3.UP


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
#region Player movement
	var direction = Vector3.ZERO
	var input_dir = Input.get_vector("3D_player_movement_right", "3D_player_movement_left", "3D_player_movement_back", "3D_player_movement_forward")
	var camera_basis = $Camera3D.global_transform.basis
	
	# Calculate movement relative to camera direction, ignoring the camera's tilt (vertical angle)
	direction = -(camera_basis.z * input_dir.y) - (camera_basis.x * input_dir.x)
	direction.y = 0 # Prevent flying
	direction = direction.normalized()
	
	
	#Player sprint
	if(Input.is_action_pressed("3D_player_sprint")):
		movement_boost_speed = sprint_speed
	else:
		movement_boost_speed = 0
	
	# Ground Velocity
	target_velocity.x = direction.x * (movement_speed + movement_boost_speed)
	target_velocity.z = direction.z * (movement_speed + movement_boost_speed)
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = max(target_velocity.y - (fall_acceleration * delta),terminal_velocity)
	elif Input.is_action_just_pressed("3D_player_jump") and is_on_floor():
		target_velocity.y = jump_height # Jump strength, can be adjusted for higher or lower jumps
	else:
		target_velocity.y = 0 # Reset vertical velocity when on the ground to prevent sliding down slopes or unintended movement
		
	# Moving the Character
	velocity = target_velocity
	move_and_slide()

#endregion

#region Player shooting
	if(Input.is_action_just_pressed("3D_player_shoot")):
		var projectile_scene = preload("res://Projectile/Projectile.tscn")
		var projectile_instance = projectile_scene.instantiate()
		var spawn_position = $Camera3D.global_transform.origin + ($Camera3D.global_transform.basis.z * -1) # Spawn in front of the camera
		projectile_instance.global_transform.origin = spawn_position
		projectile_instance.global_transform.basis = $Camera3D.global_transform.basis # Align projectile direction with camera direction
		get_parent().add_child(projectile_instance)
func _unhandled_input(event: InputEvent):
#region Player rotation
	if event is InputEventMouseMotion:
		var mouse_motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		rotation.y -= mouse_motion_event.relative.x * rotation_speed
		$Camera3D.rotation.x -= mouse_motion_event.relative.y * rotation_speed
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, PI/-2, PI/2)
#endregion
