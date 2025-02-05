class_name Unit
extends Node2D


const UNIT_SPEED := 1000


@export var stats: Stats : set = set_unit_stats

@onready var stats_label: Label = $Label

@onready var world: Node2D = $"../.."
@onready var board: TileMap = $"../../Board"


var current_id_path: Array[Vector2]
var current_path_vec: PackedVector2Array


var state: State = State.IDLE
enum State {IDLE, MOVE}


func _ready():
	Events.unit_selected.connect(_on_unit_selected)
	Events.unit_move.connect(_on_unit_move)
	stats.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()


func _process(delta):
	match state:
		State.IDLE:
			pass
		State.MOVE:
			if current_id_path.is_empty():
				return
			
			var target_position = board.map_to_local(current_id_path.front())
			
			global_position = global_position.move_toward(target_position, UNIT_SPEED * delta)
			
			if global_position == target_position:
				current_id_path.pop_front()
				
			if current_id_path.is_empty():
				Events.unit_move_ended.emit(self, current_id_path)
				state = State.IDLE


func set_unit_stats(value: Stats):
	stats = value.create_instance()


func _on_stats_changed():
	if stats is CreatureStats:
		stats_label.text = "%d/%d" % [stats.attack, stats.hp]
	else:
		stats_label.text = "%d" % stats.hp
		if stats.hp <= 0:
			print("ouch")


func _on_unit_selected(_unit: Unit):
	pass


func _on_unit_move(unit: Unit, _path: Array[Vector2]):
	if self == unit:
		state = State.MOVE
