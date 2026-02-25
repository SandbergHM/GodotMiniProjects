extends RigidBody3D

## Speed of the projectile
@export var speed : float = 5
## Lifetime of the projectile
@export var lifetime : float = 10

@onready var timer = $lifetime_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.one_shot = true
	timer.start(lifetime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer.time_left <= 0:
		queue_free()
