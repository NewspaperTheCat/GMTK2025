extends Node

var level : Level
var game_controller : GameController
var camera_rig : CameraRig
var audio_controller : AudioController
var advanced_stats : AdvancedStats

var level_progress : int = 11:
	set(value):
		if value > level_progress:
			level_progress = value
