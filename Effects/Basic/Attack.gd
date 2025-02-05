class_name AttackEffect
extends Effect

var amount := 6

func execute(owner: Unit, targets: Array[Vector2i], _map: TileMap, occupied: Dictionary) -> void:
	for at in targets:
		var defender: Unit = occupied.get(at)
		if not defender:
			continue
		if defender.stats is CreatureStats:
			defender.stats.take_damage(owner.stats.attack)
			owner.stats.take_damage(defender.stats.attack)
