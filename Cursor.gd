extends Sprite2D


@onready var top: Label = $Top
@onready var bottom: Label = $Bottom

@onready var map: TileMap = $"../../Board"
@onready var selected_map: TileMap = $"../../Selected"

@onready var world: Node2D = $"../.."

var hovered: CardUI


func _ready():
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)
	Events.card_target_selected.connect(_on_card_target_selected)
	Events.card_target_unselected.connect(_on_card_target_unselected)


func _process(_delta):
	var global_mouse_pos = world.get_global_mouse_position()
	var view_mouse_pos = get_viewport().get_mouse_position()
	global_position = view_mouse_pos
	var map_localize = map.local_to_map(global_mouse_pos)
	if map.get_cell_source_id(0, map_localize) > -1:
		selected_map.clear()
		selected_map.set_cell(0, map_localize, 0, Vector2i(0, 0))


func _on_card_target_selected(_card: CardUI, num_targets_left: int):
	bottom.text = str(num_targets_left)


func _on_card_target_unselected(_card: CardUI, num_targets_left: int):
	bottom.text = str(num_targets_left)


func _on_card_aim_started(card: CardUI, num_targets: int):
	modulate = Color.RED
	top.text = str(card.card.id)
	bottom.text = str(num_targets)


func _on_card_aim_ended(_card: CardUI):
	modulate = Color.WHITE
	top.text = "???"
	bottom.text = ""
	hovered = null


func _on_area_2d_area_entered(area):
	if world.aiming and area.get_parent() is CardUI:
		hovered = area.get_parent()
