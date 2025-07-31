class_name Level extends Node3D

@export var crowd_speed : float
var sim_timescale := 1.0

func _init() -> void:
	GM.level = self
