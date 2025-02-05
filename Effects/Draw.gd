class_name DrawEffect
extends Effect

var amount := 1

func execute(_owner: Unit, targets: Array[Vector2i], _map: TileMap, occupied: Dictionary) -> void:
	for at in targets:
		var target: Unit = occupied.get(at)
		if not target:
			continue
		for i in amount:
			var card: Card = target.stats.library.draw_card()
			target.stats.hand.add_card(card)
			Events.player_card_drawn.emit(target, card)
