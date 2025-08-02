class_name Level extends Node3D

@export var level_num : int
@export var crowd_speed : float

@onready var tutorial_label: Label = $CanvasLayer/Control/Label
@export var tutorial_text : String
var letter_speed = .05

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

func _ready() -> void:
	scrawl_tutorial()

func scrawl_tutorial():
	tutorial_label.text = ""
	
	for i in range(tutorial_text.length()):
		if not tutorial_label.visible:
			break
		
		var letter = tutorial_text[i]
		tutorial_label.text += letter
		
		if letter.to_upper() == letter or letter in "aeiou!?:":
			var beep = Global.audio_controller.generate_sfx_universal(Global.audio_controller.beep_speech_array, 6, .6, 1.8)
		
		var real_speed = letter_speed if letter not in ".,!?;:" else .75
		await get_tree().create_timer(real_speed).timeout

func hide_tutorial():
	tutorial_label.visible = false
