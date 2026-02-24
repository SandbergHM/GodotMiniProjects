extends Control

@onready var BalloonPopperButton = $BalloonPopperButton
@onready var physicsButton = $PhysicsButton
@onready var collissionButton = $CollisionButton



func _on_balloon_popper_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Baloon Popper/balloon_popper.tscn")


func _on_physics_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Physics/physics.tscn")


func _on_collision_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Collision/collision.tscn")
