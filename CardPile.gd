class_name CardPile
extends Resource


signal size_changed(size: int)

@export var cards: Array[Card] = []


func is_empty() -> bool:
	return cards.is_empty()


func draw_card() -> Card:
	var card = cards.pop_back()
	size_changed.emit(cards.size())
	return card


func add_card(card: Card) -> void:
	cards.append(card)
	size_changed.emit(cards.size())


func shuffle() -> void:
	cards.shuffle()


func _show() -> String:
	var shown: PackedStringArray = []
	for i in range(cards.size()):
		shown.append("%s: %s" % [i + 1, cards[i]])
	return "\n".join(shown)
