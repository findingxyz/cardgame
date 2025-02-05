class_name CardPileDict
extends Resource


signal size_changed(size: int)

@export var cards: Dictionary = {}

var cards_size := 0


func _init():
	cards_size


func is_empty() -> bool:
	return cards.is_empty()


func draw_card(amount) -> Array[Card]:
	var deck = cards.keys()
	#var card = cards.pop_back()
	cards_size -= amount
	size_changed.emit(cards_size)
	return []


func add_card(card: Card) -> void:
	#cards.append(card)
	size_changed.emit(cards.size())


func _show() -> String:
	var shown: PackedStringArray = []
	for i in range(cards.size()):
		shown.append("%s: %s" % [i + 1, cards[i]])
	return "\n".join(shown)
