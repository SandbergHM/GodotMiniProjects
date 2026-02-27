extends Control

@onready var BalloonPopperButton = $BalloonPopperButton
@onready var physicsButton = $PhysicsButton
@onready var collissionButton = $CollisionButton

func _enter_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_balloon_popper_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Baloon Popper/balloon_popper.tscn")

func _on_physics_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Physics/physics.tscn")

func _on_collision_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Collision/collision.tscn")

func _on_shooter_button_pressed() -> void:
	get_tree().change_scene_to_file("res://3DShooterTest/3DShooter.tscn")
