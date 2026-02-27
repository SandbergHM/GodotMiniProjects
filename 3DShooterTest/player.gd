extends CharacterBody3D

#region export variables
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
## Health
@export var health : float = 100.0
## Object throw force
@export var throw_force : float = 25.0
## Player damage
@export var player_damage : float = 5
#endregion

#region local variables
## Store last interacted object
var last_collider = null
## Velocity of the player, used for movement and gravity
var target_velocity = Vector3.ZERO
## Speed boost when the player is moving, used for sprinting or dashing mechanics
var movement_boost_speed : float = 0
## Mouse movement
var mouse_movement = Input.get_last_mouse_velocity()
## Player rotation speed
var rotation_speed: float = 0.005
#endregion

@onready var interact_line = $Interactline

## Preload projectile scene
var projectile_scene = preload("res://3DShooterTest/projectile.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	up_direction = Vector3.UP

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

#region Spawn projectile
	if Input.is_action_just_pressed("3D_player_shoot"):
		var projectile = projectile_scene.instantiate()
		var forward_direction = -$Camera3D.global_transform.basis.z.normalized()
		get_parent().add_child(projectile)
		projectile.global_transform.origin = $Camera3D.global_transform.origin + forward_direction * 1.0 
		projectile.linear_velocity = forward_direction * projectile.speed
		projectile.damage = player_damage
		
#endregion

#region Object highlight
	#rotate interact_line with camera
	interact_line.global_transform.basis = $Camera3D.global_transform.basis
	if interact_line.is_colliding():
		var collider = interact_line.get_collider()
		if collider is RigidBody3D and collider.is_in_group("interactable"):
			last_collider = collider
			var mesh_instance = collider.get_node("MeshInstance3D")
			if mesh_instance:
				mesh_instance.material_overlay = preload("res://3DShooterTest/Resources/Materials/Box_Highlight.tres")
	elif last_collider != null:
		var mesh_instance = last_collider.get_node("MeshInstance3D")
		if mesh_instance:
			mesh_instance.material_overlay = preload("res://3DShooterTest/Resources/Materials/Box.tres")
			last_collider = null
#endregion

#region Object throwing
	if Input.is_action_just_pressed("3D_player_force_throw"):
		if interact_line.is_colliding():
			var collider = interact_line.get_collider()
			if collider is RigidBody3D:	
				#get camera direction
				var forward_direction = -$Camera3D.global_transform.basis.z.normalized()
				collider.apply_impulse(forward_direction * throw_force)
#endregion

func _unhandled_input(event: InputEvent):
#region Player rotation
	if event is InputEventMouseMotion:
		var mouse_motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		rotation.y -= mouse_motion_event.relative.x * rotation_speed
		$Camera3D.rotation.x -= mouse_motion_event.relative.y * rotation_speed
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, PI/-2, PI/2)
#endregion
