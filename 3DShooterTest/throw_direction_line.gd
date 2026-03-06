extends Line2D

func _ready():
	width = 2.0
	default_color = Color.WHITE
	antialiased = true
	
	# Pre-add both points once
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)

func _process(_delta):
	var center = get_viewport_rect().size / 2
	var mouse_pos = get_viewport().get_mouse_position()
	
	set_point_position(0, center)
	set_point_position(1, mouse_pos)

func _clear():
	clear_points()
