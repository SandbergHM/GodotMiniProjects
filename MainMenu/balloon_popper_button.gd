extends MenuButton

func _on_physics_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Physics/Physics.tscn");
