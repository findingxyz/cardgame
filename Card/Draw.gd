extends Card


func apply_effects(targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var draw_effect := DrawEffect.new()
	draw_effect.amount = 1
	draw_effect.execute(owner, [map.local_to_map(owner.global_position)], map, occupied)
