class_name Stats
extends Resource


signal stats_changed


@export var max_hp := 1

var hp := max_hp


func take_damage(value):
	if value <= 0:
		return
	hp -= value
	stats_changed.emit()


func create_instance() -> Stats:
	var instance: Stats = self.duplicate()
	instance.hp = max_hp
	return instance
