extends CharacterBody3D

## Health
@export var max_health : float = 100.0
## Damage cooldown
@export var damage_cooldown : float = 1
## Maximum falling speed, used to prevent the player from falling too fast and breaking the game physics
@export var terminal_velocity : float = -50.0

# health
var health : float = max_health
# Able to take damage
var can_take_damage : bool = true
# target movement speed
var target_velocity = Vector3.ZERO
# fall acceleration
var fall_acceleration = 9.8

@onready var damagetakentimer = $DamageTakenTimer



func _physics_process(delta: float) -> void:
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = max(target_velocity.y - (fall_acceleration * delta),terminal_velocity)
	else:
		target_velocity.y = 0 # Reset vertical velocity when on the ground to prevent sliding down slopes or unintended movement
		
	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
#region damage taken
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			if collider.linear_velocity.length() > 10 and can_take_damage:
				can_take_damage = false
				health -= round(max(collider.mass, 1) * collider.linear_velocity.length() * 0.1) # Apply damage based on the force of the collision
				print(str((max(collider.mass, 1) * collider.linear_velocity.length() * 0.1)) + " damage taken")
				print(str(health) + " health remaining")
				print(collider.linear_velocity.length())
				damagetakentimer.start(damage_cooldown)
	
	# Check if the enemy is dead
	if health <= 0:
		queue_free() # Remove the enemy from the scene
#endregion

func _on_damagetakentimer_timeout() -> void:
	can_take_damage = true
	print("can take damage")
