extends Node3D

@export var broken_model:PackedScene
@export var health:int = 1


func _physics_process(delta: float) -> void:

	
#region damage taken

	#Check Node3D for collissions and apply damage based on the force of the collision
	for collision in self.g
		if collision.collider is RigidBody3D:
			var damage = collision.collider.linear_velocity.length() * 0.1
			health -= int(damage)
	
	# Check if the enemy is dead
	if health <= 0:
		var broken_model_inst:Node3D = broken_model.instantiate()
		
		get_parent().add_child(broken_model_inst)
		broken_model_inst.transform = self.transform
		
		self.queue_free()
#endregion
