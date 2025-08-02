extends Node

var level : Level
var game_controller : GameController
var camera_rig : CameraRig
var audio_controller : AudioController

var level_progress : int = 3:
	set(value):
		if value > level_progress:
			level_progress = value
