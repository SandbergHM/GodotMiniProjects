extends CharacterBody3D

## Health
@export var max_health : float = 20
## Damage cooldown
@export var damage_cooldown : float = 0.1
## Maximum falling speed, used to prevent the player from falling too fast and breaking the game physics
@export var terminal_velocity : float = -50.0
## Movement speed
@export var movement_speed : float = 5.0
## Enable following the player
@export var enable_follow : bool = true

## Enemy health
var health : float = max_health
## Able to take damage
var can_take_damage : bool = true
## target movement speed
var target_velocity = Vector3.ZERO
# fall acceleration
var fall_acceleration = 9.8

@onready var damagetakentimer = $DamageTakenTimer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player: Node3D
var time_since_update: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	# Configure navigation
	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 10
	nav_agent.target_position = player.global_position
	await get_tree().process_frame

func _physics_process(delta: float) -> void:
#region enemy movement
	var flat_player_pos = Vector2(player.global_position.x, player.global_position.z)
	var flat_self_pos = Vector2(global_position.x, global_position.z)
	var distance_to_player = flat_self_pos.distance_to(flat_player_pos)
	
	# Stop moving if within desired distance
	if distance_to_player <= nav_agent.target_desired_distance:
		velocity.x = 0.0
		velocity.z = 0.0
		# Still apply gravity
		if not is_on_floor():
			velocity.y -= 9.8 * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		return

	# Only update target if we need to keep moving
	nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		return
		
	var next_pos = nav_agent.get_next_path_position()
	var diff = next_pos - global_position
	var direction = Vector3(diff.x, 0, diff.z).normalized()
	if direction.length() < 0.001:
		return

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	
	move_and_slide()
#endregion
	
#region damage taken
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			if collider.linear_velocity.length() > 10 and can_take_damage:
				can_take_damage = false
				health -= round(max(collider.mass, 1) * collider.linear_velocity.length() * 0.1) 
				damagetakentimer.start(damage_cooldown)
	
	# Check if the enemy is dead
	if health <= 0:
		#await collision on project side
		await get_tree().process_frame
		await get_tree().process_frame
		queue_free() # Remove the enemy from the scene
#endregion

func _on_damagetakentimer_timeout() -> void:
	#can_take_damage = true
	print("can take damage")
