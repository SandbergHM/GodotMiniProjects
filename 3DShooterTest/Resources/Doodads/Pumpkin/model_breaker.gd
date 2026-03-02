extends Node3D

@export  var intensity : float = 1.0

func _ready():
	for pieces:RigidBody3D in self.get_children():
		pieces.apply_impulse(pieces.get_child(0).position * intensity, self.global_position)
	
	await self.get_tree().create_timer(5).timeout
	globals._texture_fadeout(self, 2.0)
