class_name MoveEffect
extends Effect

var amount := 6

func execute(owner: Unit, _targets: Array[Vector2i], _map: TileMap, _occupied: Dictionary) -> void:
	if owner.stats is CharacterStats:
		owner.stats.move += amount
