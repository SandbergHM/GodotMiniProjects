extends RigidBody2D

##Force applied to player when clicking
@export var hit_force : float = 50.0
##Explosion power
@export var impulse_power: float = 50.0
##Explosion range
@export var range: float = 100.0
##Explosion destruction range
@export var destruction_range: float = 50.0

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

				#Player --> Node direction
				var direction: Vector2 = node.global_position - position
				#Player --> Node distance
				var distance: float = direction.length()
				
				if node.get_scene_file_path() == "res://Physics/crate.tscn":
					#Destroy crate if too close to explosion
					if (distance < destruction_range):
						node.queue_free()
					#Apply force if within range
					elif (distance < range):
						node.apply_impulse(direction.normalized() * impulse_power)
