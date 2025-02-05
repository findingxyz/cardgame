class_name SummonEffect
extends Effect


var summoned_unit: Resource


func execute(owner: Unit, targets: Array[Vector2i], map: TileMap, occupied: Dictionary):
	for at in targets:
		var unit: Unit = summoned_unit.instantiate()
		unit.global_position = map.map_to_local(at)
		unit.stats = CreatureStats.new()
		unit.stats.attack = 1
		unit.stats.max_move = 3
		unit.stats.move = unit.stats.max_move
		owner.stats.controlling.append(unit)
		map.get_parent().get_node("Units").add_child(unit)
		occupied[at] = unit
