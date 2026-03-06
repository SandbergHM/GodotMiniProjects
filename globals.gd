extends Node
class_name globals

#region scene path constants
const PROJECTILE_SCENE_PATH = "res://3DShooterTest/Resources/Projectiles/projectile.tscn"
const PUMPKIN_PROJECTILE_SCENE_PATH = "res://3DShooterTest/Resources/Projectiles/pumpkin_projectile.tscn"
const FALL_ACCELERATION = 9.8
#endregion



static func _model_shatter(node: Node, shattered_scene: PackedScene):
		
	var broken_model:Node3D = shattered_scene.instantiate()
	node.get_parent().add_child(broken_model)
	broken_model.transform = node.transform

	node.queue_free()


#Gradually fade out an object over "fade_time" value
static func _texture_fadeout(node: Node, fade_time : float):
	for body in node.get_children():
		if body is RigidBody3D:
			var mesh = body.get_node_or_null("inner material_cell")  # Adjust node name to match yours
			if mesh == null:
				continue
			
			var material = mesh.get_active_material(0).duplicate()
			mesh.set_surface_override_material(0, material)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
			var tween = node.create_tween()
			tween.tween_property(material, "albedo_color:a", 0.0, fade_time)

	# Wait for the fade to finish, then free the root Node3D
	
	node.queue_free()
	
