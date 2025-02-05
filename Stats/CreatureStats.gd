class_name CreatureStats
extends Stats


@export var attack := 0
@export var max_move := 0

var move := 0


func create_instance() -> CreatureStats:
	var instance: CreatureStats = self.duplicate()
	instance.hp = max_hp
	instance.move = 0
	return instance
