extends Card


@export var unit: Resource


func apply_effects(targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var summon_effect := SummonEffect.new()
	summon_effect.summoned_unit = unit
	summon_effect.execute(owner, targets, map, occupied)
