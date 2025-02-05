class_name CharacterStats
extends CreatureStats

@export var max_mana := 0

var mana := max_mana

@export var deck: CardPile
var library: CardPile
var basic_hand: CardPile
var hand: CardPile
var graveyard: CardPile


var controlling: Array[Unit]


func create_instance() -> CharacterStats:
	var instance: CharacterStats = self.duplicate()
	instance.hp = max_hp
	instance.move = 0
	instance.mana = max_mana
	instance.library = deck.duplicate()
	instance.basic_hand = CardPile.new()
	instance.hand = CardPile.new()
	instance.graveyard = CardPile.new()
	return instance
