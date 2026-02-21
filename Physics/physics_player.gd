extends RigidBody2D

##Force applied to player when clicking
@export var hit_force : float = 50.0
##Explosion power
@export var impulse_power: float = 50.0
##Explosion range
@export var range: float = 100.0

func _process (delta):
	#Player movement
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		
		#get mouse position
		var mouse_pos = get_global_mouse_position()
		
		#get mouse direction from player
		var mouse_dir = global_position.direction_to(mouse_pos)
		
		#apply force
		apply_impulse(mouse_dir * hit_force)
	
	#Right-click explosion testing
	if Input.is_action_just_pressed("explosion"):
		for node: Node in get_parent().get_children():
			if node is RigidBody2D:
				#Get mouse position
				var mouse_position = get_global_mouse_position()
				#Mouse --> Node direction
				var direction: Vector2 = node.global_position - mouse_position
				#Mouse --> Node distance
				var distance: float = direction.length()
				
				#Apply force if within range
				if distance < range:
					node.apply_impulse(direction.normalized() * impulse_power)
