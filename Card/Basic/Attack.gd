extends Card


func apply_effects(targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var attack_effect := AttackEffect.new()
	attack_effect.execute(owner, targets, map, occupied)
