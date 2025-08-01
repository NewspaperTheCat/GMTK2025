class_name Level extends Node3D

@export var level_num : int
@export var crowd_speed : float
var sim_timescale := 1.0

enum game_state { DEFAULT, GOLFING, CUTSCENE }
var current_game_state : game_state = game_state.GOLFING

func _init() -> void:
	Global.level = self
