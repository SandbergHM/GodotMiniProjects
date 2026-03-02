extends RigidBody3D

## Speed of the projectile
@export var speed : float = 50
## Lifetime of the projectile
@export var lifetime : float = 10
## Projectile damage
@export var damage : float = 5
## Collision model
@export var broken_model:PackedScene

@onready var timer = $lifetime_timer

func _ready() -> void:
	#Activate projectile lifetime control
	timer.one_shot = true
	timer.start(lifetime)
	mass = damage


func _process(delta: float) -> void:
	#Remove projectile after set time to avoid cluttering the scene with unused projectiles
	if timer.time_left <= 0:
		queue_free()



func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if not body.is_in_group("projectile_do_not_react") and not body.is_in_group("Player") and not body.is_in_group("Projectiles"):		
		globals._model_shatter(self, broken_model)
	pass
	#Do not react to player or other projectiles
	if not body.is_in_group("projectile_do_not_react") and not body.is_in_group("Player") and not body.is_in_group("Projectiles"):		
		var broken_model_inst = broken_model.instantiate()
		
		get_parent().add_child(broken_model_inst)
		broken_model_inst.transform = self.transform
		print(body.name)
		
		self.queue_free()
	
