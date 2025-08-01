extends Node

var level : Level
var game_controller : GameController
var camera_rig : CameraRig

var level_progress : int = 0:
	set(value):
		if value > level_progress:
			level_progress = value

const AUDIO_STREAM_3D = preload("res://Audio/SFX/AudioStream3D.tscn")

var beep_speech_folder_path = "res://Audio/SFX/BeepSpeech/"
var beep_speech_array : Array[AudioStream] = []

func _ready() -> void:
	# Fill beep_speech_array
	var dir := DirAccess.open(beep_speech_folder_path)
	var file_names := dir.get_files()
	for file_name in file_names:
		if file_name.right(7) != ".import":
			beep_speech_array.append(load(beep_speech_folder_path + file_name))
