extends Node


signal card_drag_started(card: CardUI)
signal card_drag_ended(card: CardUI)

signal card_aim_started(card: CardUI, num_targets: int)
signal card_aim_ended(card: CardUI)

signal card_target_selected(card: CardUI, num_targets_left: int)
signal card_target_unselected(card: CardUI, num_targets_left: int)

signal card_played(card: CardUI)

signal unit_selected(unit: Unit)
signal unit_unselected(unit: Unit)

signal active_player_changed(active_player: Unit)
signal player_card_drawn(player: Unit, card: Card)

signal unit_move_ended(unit: Unit, path: Array[Vector2])
signal unit_move(unit: Unit, path: Array[Vector2])

signal turn_started
signal turn_ended
