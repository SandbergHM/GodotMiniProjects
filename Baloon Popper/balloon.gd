extends Area3D

## Clicks needed to pop balloon
@export var clicks_to_pop : int = 5
## Scale increase of balloon per click
@export var size_increase : float = 0.1
## Score gained per popped balloon
@export var score_to_give : int  = 1

var manager

func _ready ():
	manager = $".."

func _on_input_event(camera, event, event_position, normal, shape_idx) -> void:
	
	#filter out none mouseclicks
	if event is not InputEventMouseButton:
		return
	#filter out none leftclick events
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	#filter out non pressed events
	if not event.pressed:
		return
	
	scale += Vector3.ONE * size_increase
	clicks_to_pop -= 1;
	
	if clicks_to_pop == 0:
		manager.increase_score(score_to_give)
		queue_free()
		
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
