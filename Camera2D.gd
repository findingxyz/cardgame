extends Camera2D


func _process(_delta):
	var dir = Vector2(
		int(Input.is_action_pressed("right_arrow")) - int(Input.is_action_pressed("left_arrow")),
		int(Input.is_action_pressed("down_arrow")) - int(Input.is_action_pressed("up_arrow"))
		)#.normalized()
	global_position += dir * 5
