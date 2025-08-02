class_name TransitionController extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func transition(animation: String, seconds: float = .4):
	animation_player.play(animation, -1.0, 1 / seconds)
	if "Out" in animation:
		Global.audio_controller.generate_sfx_universal(Global.audio_controller.woosh_array)
		audio_stream_player.pitch_scale = randf_range(.7, 1.3)
		audio_stream_player.play()
