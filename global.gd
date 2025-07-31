extends Node

var level_progress : int = 0:
	set(value):
		if value > level_progress:
			level_progress = value
var level : Level
var game_controller : GameController
