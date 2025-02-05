class_name World
extends Node2D


@onready var board: TileMap = $Board
@onready var units: Node2D = $Units
@onready var ui: CanvasLayer = $CanvasLayer

@onready var cursor = $CanvasLayer/Cursor
@onready var selected_cursor = $Selected2

@onready var basic_hand: HBoxContainer = $CanvasLayer/BasicHand
@onready var hand: HBoxContainer = $CanvasLayer/Hand

@onready var card_UI := preload("res://CardUI.tscn")

var astar_grid: AStar2D

var occupied_tiles: Dictionary

var active_player: Unit
var players: Array[Unit]
var player_index = 0

var selected_unit: Unit
var prev_pos: Vector2i

var targets: Array[Vector2i]
#var targets: Dictionary

var aiming := false
var selected_card_ui: CardUI
var dragging := false
var drag_offset: Vector2

@export var spell: Card
var current_spell: Card = null

@onready var turn_info: Label = $CanvasLayer/TurnInfo

@export var basic_hand_pile: CardPile

var at: PackedVector2Array = [Vector2(0, 0), Vector2(100, 100)]


func _init():
	set_as_top_level(true)

func _ready():
	#randomize()
	seed(42)
	astar_grid = AStar2D.new()
	
	selected_cursor.hide()
	
	for x in board.get_used_rect().size.x:
		for y in board.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + board.get_used_rect().position.x,
				y + board.get_used_rect().position.y
			)
			var tile_data = board.get_cell_tile_data(0, tile_position)
			if tile_data:
				astar_grid.add_point(hash(tile_position), tile_position)
				for neighbour in board.get_surrounding_cells(tile_position):
					if board.get_cell_tile_data(0, neighbour) and astar_grid.has_point(hash(neighbour)):
						astar_grid.connect_points(
							hash(tile_position),
							hash(neighbour)
						)
	update_occupied_tiles()
	
	Events.card_drag_started.connect(_on_card_drag_started)
	Events.card_drag_ended.connect(_on_card_drag_ended)
	
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)
	
	Events.card_played.connect(_on_card_played)
	
	Events.active_player_changed.connect(_on_active_player_changed)
	Events.player_card_drawn.connect(_on_player_card_drawn)
	
	Events.unit_move_ended.connect(_on_unit_move_ended)
	
	Events.turn_started.connect(_on_turn_started)
	Events.turn_ended.connect(_on_turn_ended)
	
	Events.unit_selected.connect(_on_unit_selected)
	Events.unit_unselected.connect(_on_unit_unselected)
	Events.unit_move.connect(_on_unit_move)
	
	ui.get_node("AimArea").mouse_entered.connect(_on_aim_mouse_entered)
	ui.get_node("AimArea").mouse_exited.connect(_on_aim_mouse_exited)
	
	for child in units.get_children():
		if child is Unit and child.stats is CharacterStats:
			for i in range(3):
				child.stats.hand.add_card(child.stats.library.draw_card())
			players.append(child)
	players.shuffle()
	active_player = players[0]
	Events.active_player_changed.emit(active_player)


func _input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		at[0] = get_global_mouse_position()
	if event.is_action_released("left_click"):
		at[1] = get_global_mouse_position()
	if event.is_action_released("cast"):
		$Line2D.points = at
		$Line2D/Label.text = str(Vector2(board.local_to_map(at[0])).distance_to(board.local_to_map(at[1])))
	if dragging and selected_card_ui and not aiming:
		selected_card_ui.global_position = get_global_mouse_position() + drag_offset
	if event.is_action_released("left_click"):
		pass


func _unhandled_input(event: InputEvent):
	var target_pos = board.local_to_map(get_global_mouse_position())
	var target = occupied_tiles.get(target_pos)
	if event.is_action_pressed("right_click"):
		if aiming:
			aiming = false
			Events.card_aim_ended.emit(selected_card_ui)
			Events.card_drag_ended.emit(selected_card_ui)
			$Targetable.clear()
		elif dragging:
			dragging = false
			Events.card_drag_ended.emit(selected_card_ui)
		#selected_unit = null
		#selected_cursor.hide()
	if aiming:
		if event.is_action_released("left_click"):
			if current_spell:
				var neighbours: Array[Unit] = _neighbours_of_point(board.local_to_map(active_player.global_position))
				$Targetable.draw($Targetable._flood_fill(board.local_to_map(active_player.global_position), current_spell.target_range))
				if current_spell._check_target(target_pos, board, occupied_tiles):
					if targets.size() < current_spell.num_targets:
						if target_pos not in targets:
							#targets[target_pos] = true
							targets.append(target_pos)
							Events.card_target_selected.emit(selected_card_ui, current_spell.num_targets - targets.size())
						else:
							targets.erase(target_pos)
							Events.card_target_unselected.emit(selected_card_ui, current_spell.num_targets - targets.size())
					if targets.size() >= current_spell.num_targets:
						current_spell.play(targets, board, occupied_tiles)
						#current_spell.play(targets.keys(), board, occupied_tiles)
						Events.card_played.emit(selected_card_ui)
						#current_spell = null
				elif current_spell.target_type == current_spell.Target.CUSTOM:
					cursor.top.text = "targeting card"
					if cursor.hovered and cursor.hovered != selected_card_ui:
						print("woo")
						current_spell.play(targets, board, occupied_tiles)
						#current_spell.play(targets.keys(), board, occupied_tiles)
						active_player.stats.hand.cards.erase(cursor.hovered.card)
						cursor.hovered.queue_free()
						Events.card_played.emit(selected_card_ui)
	else:
		if event.is_action_pressed("left_click"):
			if target:
				Events.unit_selected.emit(target)
				#if selected_unit.stats is CharacterStats:
					#active_player = selected_unit
					#Events.active_player_changed.emit(active_player)
				#prev_pos = board.local_to_map(selected_unit.global_position)
		#if event.is_action_released("left_click"):
			#if selected_unit:
				#if not occupied_tiles.get(target_pos):
					#update_selected_unit_position(target_pos)
				#else:
					#update_selected_unit_position(prev_pos)
		#if selected_unit:
			#selected_unit.global_position = get_global_mouse_position()
			elif selected_unit and event.is_action_pressed("left_click"):
				if selected_unit and selected_unit.stats.move > 0:
					if astar_grid.has_point(hash(target_pos)):
						var id_path = astar_grid.get_id_path(
							hash(board.local_to_map(selected_unit.global_position)),
							hash(target_pos)
						).slice(1)
						if not id_path.is_empty() and id_path.size() <= selected_unit.stats.move:
							var current_id_path: Array[Vector2] = []
							for id in id_path:
								current_id_path.push_back(astar_grid.get_point_position(id))
							var current_path_vec: PackedVector2Array = [selected_unit.global_position]
							for i in range(current_id_path.size()):
								current_path_vec.push_back(board.map_to_local(current_id_path[i]))
							selected_unit.current_id_path = current_id_path
							selected_unit.current_path_vec = current_path_vec
						update_occupied_tiles()


func _process(_delta):
	queue_redraw()
	if active_player:
		turn_info.text = "%s\n%d\n%d" % [active_player.name, active_player.stats.mana, active_player.stats.move]
	if selected_unit:
		selected_cursor.global_position.x = selected_unit.global_position.x
		selected_cursor.global_position.y = selected_unit.global_position.y - 64


func _draw():
	if not selected_unit:
		return
	if selected_unit.current_path_vec.is_empty():
		return
	
	if selected_unit.current_path_vec.size() > 2:
		draw_polyline(selected_unit.current_path_vec, Color.WHITE, 8)


func update_selected_unit_position(pos: Vector2i) -> void:
	selected_unit.global_position = board.map_to_local(pos)
	selected_unit = null
	update_occupied_tiles()


func update_occupied_tiles():
	for at in occupied_tiles.keys():
		astar_grid.set_point_disabled(hash(at), false)
	occupied_tiles.clear()
	for unit in units.get_children():
		var at = board.local_to_map(unit.global_position)
		occupied_tiles[at] = unit
		astar_grid.set_point_disabled(hash(at))


func _on_card_gui_input(card: CardUI, event: InputEvent):
	if not dragging or not aiming:
		if event.is_action_pressed("left_click"):
			dragging = true
			selected_card_ui = card
			drag_offset = card.global_position - get_global_mouse_position()
			Events.card_drag_started.emit(card)
		if event.is_action_released("left_click"):
			if not aiming:
				dragging = false
				selected_card_ui = null
				Events.card_drag_ended.emit(card)


func _on_card_drag_started(card: CardUI):
	card.reparent(ui)


func _on_card_drag_ended(card: CardUI):
	dragging = false
	if card.card.basic:
		card.reparent(basic_hand)
	else:
		card.reparent(hand)


func _on_aim_mouse_entered():
	if dragging and not aiming and selected_card_ui and selected_card_ui.card._can_cast(active_player.stats.mana):
		aiming = true
		Events.card_aim_started.emit(selected_card_ui, selected_card_ui.card.num_targets)


func _on_aim_mouse_exited():
	return

func _on_card_aim_started(card: CardUI, _num_targets: int):
	current_spell = card.card


func _on_card_aim_ended(_card: CardUI):
	aiming = false
	targets.clear()


func _on_card_played(card: CardUI):
	dragging = false
	active_player.stats.mana -= selected_card_ui.card.mana_cost
	selected_card_ui = null
	Events.card_aim_ended.emit(card)
	Events.card_drag_ended.emit(card)
	active_player.stats.hand.cards.erase(card.card)
	card.queue_free()
	$Targetable.clear()
	update_occupied_tiles()


func _on_active_player_changed(target: Unit):
	Events.unit_selected.emit(target)
	if selected_unit.stats is CharacterStats:
		active_player = selected_unit
		#Events.active_player_changed.emit(active_player)
	prev_pos = board.local_to_map(selected_unit.global_position)
	for card in basic_hand.get_children():
		card.queue_free()
	for card in basic_hand_pile.cards: #active_player.stats.basic_hand.cards:
		var card_ui = card_UI.instantiate()
		card_ui.card = card
		card_ui.card.owner = active_player
		basic_hand.add_child(card_ui)
	for child in ui.get_node("BasicHand").get_children():
		if child is CardUI and not child.card_gui_input.is_connected(_on_card_gui_input):
			child.card_gui_input.connect(_on_card_gui_input)
	for card in hand.get_children():
		card.queue_free()
	for card in active_player.stats.hand.cards:
		var card_ui = card_UI.instantiate()
		card_ui.card = card
		card_ui.card.owner = active_player
		hand.add_child(card_ui)
	for child in ui.get_node("Hand").get_children():
		if child is CardUI and not child.card_gui_input.is_connected(_on_card_gui_input):
			child.card_gui_input.connect(_on_card_gui_input)
	Events.turn_started.emit()


func _on_unit_move_ended(unit: Unit, path: Array[Vector2]):
	update_occupied_tiles()
	unit.stats.move -= path.size()


func _on_turn_started():
	if active_player:
		active_player.stats.basic_hand.cards = basic_hand_pile.cards
		active_player.stats.hand.add_card(active_player.stats.library.draw_card())
		active_player.stats.mana = active_player.stats.max_mana


func _on_turn_ended():
	pass


func _on_button_pressed():
	player_index = (player_index + 1) % players.size()
	active_player = players[player_index]
	Events.active_player_changed.emit(active_player)


func _neighbours_of_point(pos: Vector2i) -> Array[Unit]:
	var neighbours: Array[Unit] = []
	for n in [Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
		var neighbour: Unit = occupied_tiles.get(pos + n)
		if neighbour and neighbour is Unit:
			neighbours.append(neighbour)
	return neighbours


func _on_unit_selected(unit: Unit):
	if unit == active_player or unit in active_player.stats.controlling:
		selected_unit = unit
		selected_cursor.show()


func _on_unit_unselected(_unit: Unit):
	selected_unit = null
	selected_cursor.hide()


func _on_player_card_drawn(player: Unit, card: Card):
	if player == active_player:
		var card_ui = card_UI.instantiate()
		card_ui.card = card
		card_ui.card.owner = active_player
		hand.add_child(card_ui)


func _on_unit_move(unit: Unit, _path: Array[Vector2]):
	unit.stats.move -= unit.current_id_path.size()


func _on_move_pressed():
	var empty: Array[Vector2] = []
	Events.unit_move.emit(selected_unit, empty)
