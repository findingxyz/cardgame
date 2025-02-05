extends TileMap


const DIRECTIONS = [Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]


func draw(cells):
	clear()
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(0, 0))


func _flood_fill(cell: Vector2i, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()
		
		if get_cell_source_id(0, current) > -1:
			continue

		#if not is_within_bounds(current):
			#continue
		if current in array:
			continue

		var difference: Vector2i = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		var cellv := Vector2(cell)
		distance = map_to_local(cellv).distance_to(map_to_local(current))
		if distance > max_distance * 125:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			#if is_occupied(coordinates):
				#continue
			if coordinates in array:
				continue

			stack.append(coordinates)
	return array
