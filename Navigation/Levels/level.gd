class_name Level extends Node3D

@export var level_num : int
@export var crowd_speed : float

signal timescale_changed
var sim_timescale := 1.0:
	set(value):
		sim_timescale = value
		timescale_changed.emit(value)


enum game_state { DEFAULT, GOLFING, CUTSCENE }
signal game_state_changed
var current_game_state : game_state = game_state.GOLFING:
	set(value):
		current_game_state = value
		game_state_changed.emit(value)

func _init() -> void:
	Global.level = self
