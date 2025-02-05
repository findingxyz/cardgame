extends Card


func apply_effects(_targets: Array[Vector2i], map: TileMap, occupied: Dictionary) -> void:
	var gild_effect := GildEffect.new()
	gild_effect.execute(owner, [], map, occupied)
