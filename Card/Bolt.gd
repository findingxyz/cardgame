extends Card


func apply_effects(targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 3
	damage_effect.execute(owner, targets, map, occupied)
