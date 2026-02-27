extends RigidBody3D

## Speed of the projectile
@export var speed : float = 50
## Lifetime of the projectile
@export var lifetime : float = 10
## Projectile damage
@export var damage : float = 5

signal health_depleted

@onready var timer = $lifetime_timer

func _ready() -> void:
	#Activate projectile lifetime control
	timer.one_shot = true
	timer.start(lifetime)


func _process(delta: float) -> void:
	#Remove projectile after set time to avoid cluttering the scene with unused projectiles
	if timer.time_left <= 0:
		queue_free()


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	#Do not react to player or other projectiles
	if not body.is_in_group("Player") and not body.is_in_group("Projectiles"):		
		queue_free()
		
