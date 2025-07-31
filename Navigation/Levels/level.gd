class_name Level extends Node3D

@export var level_num : int
@export var crowd_speed : float
var sim_timescale := 1.0

func _init() -> void:
	Global.level = self
