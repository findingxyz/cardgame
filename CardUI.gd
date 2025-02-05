class_name CardUI
extends Control


signal card_gui_input(card: Control, event: InputEvent)

@export var card: Card

@onready var card_name: Label = $Name
@onready var card_description: Label = $Description


func _ready():
	gui_input.connect(_on_gui_input)
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)
	card_name.text = str(card.id)
	card_description.text = card.description


func _on_gui_input(event: InputEvent):
	card_gui_input.emit(self, event)


func _on_card_aim_started(card_ui: CardUI, _num_targets: int):
	if self == card_ui:
		modulate = Color.BLUE


func _on_card_aim_ended(card_ui: CardUI):
	if self == card_ui:
		modulate = Color.WHITE
