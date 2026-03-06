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
@export var fall_acceleration = globals.FALL_ACCELERATION
## Health
@export var health : float = 100.0
## Object throw force
@export var throw_force : float = 25.0
## Player damage
@export var player_damage : float = 5
## Minimum time the throw button needs to be held to charge the throw, used to differentiate between a normal throw and a charged throw
@export var min_hold_time: float = 0.1  # tune this
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
## Lock player rotation
var rotation_locked: bool = false
## Lock player movement
var movement_locked: bool = false
## Check if throw button was pressed to keep track of the throw charge timer
var throw_button_pressed: bool = false

var suck_object_to_player_tween: Tween

#endregion

@onready var throw_charge_timer = $ThrowChargeTimer
@onready var interact_line = $Interactline
@onready var throw_direction = $CanvasLayer/ThrowDirectionLine

## Preload projectile scene
var projectile_scene = preload(globals.PUMPKIN_PROJECTILE_SCENE_PATH)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	throw_charge_timer.wait_time = min_hold_time
	up_direction = Vector3.UP
	throw_direction.width = 0

func _physics_process(delta: float) -> void:
	rotation_locked = false
	movement_locked = false

#region Spawn projectile
	if Input.is_action_just_pressed("3D_player_shoot"):
		var projectile = projectile_scene.instantiate()
		var forward_direction = -$Camera3D.global_transform.basis.z.normalized()
		get_parent().add_child(projectile)
		projectile.global_transform.origin = $Camera3D.global_transform.origin + forward_direction * 1.1 
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
	#Check if player is pressing or holding throw button
	if Input.is_action_pressed("3D_player_force_throw"):
		if interact_line.is_colliding():
			var collider = interact_line.get_collider()
			if collider is RigidBody3D:	
				if throw_charge_timer.is_stopped() and not throw_button_pressed:
					throw_charge_timer.start()
					Input.warp_mouse(get_viewport().size / 2)
					throw_button_pressed = true
					rotation_locked = true
					movement_locked = true
					get_tree().process_frame
				elif throw_button_pressed and (throw_charge_timer.wait_time - throw_charge_timer.time_left) >= min_hold_time and collider.is_in_group("Liftable"):
					#Move object to in front of player while charging throw
					var object_hover_location = $Camera3D.global_transform.origin + (-$Camera3D.global_transform.basis.z.normalized() * 2)
					if suck_object_to_player_tween == null or not suck_object_to_player_tween.is_running():
						suck_object_to_player_tween = create_tween()
						suck_object_to_player_tween.set_trans(Tween.TRANS_EXPO)
						suck_object_to_player_tween.set_ease(Tween.EASE_OUT)
						suck_object_to_player_tween.tween_property(collider, "global_transform:origin", object_hover_location, 0.5)
					Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
					throw_direction.width = 10
					rotation_locked = true
					movement_locked = true
		else:
			throw_direction.width = 0
			throw_button_pressed = false
			stop_charge_tween()
			
	#Determine if throw should be charge or not
	if Input.is_action_just_released("3D_player_force_throw"):
		if interact_line.is_colliding():
			var collider = interact_line.get_collider()
			if collider is RigidBody3D:	
				if throw_charge_timer.time_left > 0:
					stop_charge_tween()
					var forward_direction = -$Camera3D.global_transform.basis.z.normalized()
					collider.apply_impulse(forward_direction * throw_force)
					throw_charge_timer.stop()
					throw_button_pressed = false
					throw_direction.width = 0
				else:
					stop_charge_tween()
					collider.apply_impulse(get_launch_direction() * throw_force)
					throw_charge_timer.stop()
					throw_button_pressed = false
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					throw_direction.width = 0
#endregion

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
	if not is_on_floor(): # If in the air, fall towards the floor
		target_velocity.y = max(target_velocity.y - (fall_acceleration * delta),terminal_velocity)
	elif Input.is_action_just_pressed("3D_player_jump") and is_on_floor():
		target_velocity.y = jump_height
	else:
		target_velocity.y = 0 
		
	# Moving the Character
	velocity = target_velocity
	if not movement_locked:
		move_and_slide()
#endregion

func _unhandled_input(event: InputEvent):
#region Player rotation
	if not rotation_locked:
		if event is InputEventMouseMotion:
			var mouse_motion_event: InputEventMouseMotion = event as InputEventMouseMotion
			rotation.y -= mouse_motion_event.relative.x * rotation_speed
			$Camera3D.rotation.x -= mouse_motion_event.relative.y * rotation_speed
			$Camera3D.rotation.x = clampf($Camera3D.rotation.x, PI/-2, PI/2)
#endregion

func get_launch_direction() -> Vector3:
	var viewport = get_viewport()
	var screen_center = viewport.get_visible_rect().size / 2.0
	var mouse_pos = viewport.get_mouse_position()

	var offset = (mouse_pos - screen_center) / screen_center

	var camera = get_viewport().get_camera_3d()
	var cam_right = camera.global_transform.basis.x
	var cam_up    = -camera.global_transform.basis.y

	var direction = cam_right * offset.x + cam_up * offset.y
	return direction.normalized()

func stop_charge_tween():
	if suck_object_to_player_tween:
		suck_object_to_player_tween.stop()
		suck_object_to_player_tween = null
