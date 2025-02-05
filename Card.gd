class_name Card
extends Resource


@export var id: StringName
@export var basic: bool
@export var mana_cost: int
@export var num_targets: int
@export var target_type: Target
@export var target_range: int

@export var description: String

var card_cost: Array

var owner: Unit

enum Target {SELF, MINIONS, STRUCTURES, ALLIES, ENEMIES, UNITS, BOARD, CUSTOM}


func _can_cast(current_mana: int, _other_used: Array = []) -> bool:
	if current_mana >= mana_cost:
		return true
	return false


func _check_target(target: Vector2i, map: TileMap, occupied: Dictionary) -> bool:
	if target_type == Target.SELF and num_targets <= 1:
		if owner.stats is CharacterStats:
			return true
	var unit_target: Unit = occupied.get(target)
	print(owner.global_position, " ", map.map_to_local(target).distance_to(owner.global_position))
	if target_range < 1 or map.map_to_local(target).distance_to(owner.global_position) <= target_range * 128:
		if unit_target and unit_target.stats is Stats:
			match target_type:
				Target.MINIONS:
					if unit_target.stats is CreatureStats:
						return true
				Target.STRUCTURES:
					if not unit_target.stats is CreatureStats:
						return true
				Target.ALLIES:
					return false
				Target.ENEMIES:
					return false
				Target.UNITS:
					return true
				Target.BOARD:
					if occupied.get(target):
						return false
					return true
				_:
					return false
		elif target_type == Target.BOARD:
			#if occupied.get(target):
				#return false
			return true
	return false


func play(targets: Array[Vector2i], map: TileMap, occupied: Dictionary, _other_costs: Array = []) -> void:
	#Events.card_played.emit()
	match target_type:
		Target.SELF:
			apply_effects([], map, occupied)
		_:
			#var unit_targets: Array[Unit] = []
			#for target in targets:
				#if not occupied.get(target):
					#continue
				#unit_targets.append(occupied[target])
			#apply_effects(unit_targets, map, occupied)
			apply_effects(targets, map, occupied)


func apply_effects(_targets: Array[Vector2i], _map: TileMap, _occupied: Dictionary) -> void:
#func apply_effects(_targets: Array, _map: TileMap, _occupied: Dictionary) -> void:
	pass
