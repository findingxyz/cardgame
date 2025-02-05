extends Card


func apply_effects(targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var vitalize_effect := VitalizeEffect.new()
	vitalize_effect.amount = 3
	vitalize_effect.execute(owner, targets, map, occupied)
