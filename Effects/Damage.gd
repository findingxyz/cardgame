class_name DamageEffect
extends Effect

var amount := 0

func execute(_owner: Unit, targets: Array[Vector2i], _map: TileMap, occupied: Dictionary) -> void:
	for at in targets:
		var target: Unit = occupied.get(at)
		if not target:
			continue
		target.stats.take_damage(amount)
