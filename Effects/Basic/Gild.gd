class_name GildEffect
extends Effect

var amount := 1

func execute(owner: Unit, _targets: Array[Vector2i], _map: TileMap, _occupied: Dictionary) -> void:
	if owner.stats is CharacterStats:
		owner.stats.max_mana += amount
		owner.stats.mana += amount
