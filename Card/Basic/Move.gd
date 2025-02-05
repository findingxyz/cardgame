extends Card


func apply_effects(targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var move_effect := MoveEffect.new()
	move_effect.amount = 6
	move_effect.execute(owner, targets, map, occupied)
