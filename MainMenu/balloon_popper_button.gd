extends MenuButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Baloon Popper/balloon_popper.tscn")
