class_name AudioController extends AudioStreamPlayer


const AUDIO_STREAM_3D = preload("res://Audio/SFX/AudioStream3D.tscn")
const AUDIO_STREAM = preload("res://Audio/SFX/AudioStream.tscn")

var beep_speech_folder_path = "res://Audio/SFX/BeepSpeech/"
var beep_speech_array : Array[AudioStream] = []

var mouse_click_folder_path = "res://Audio/SFX/MouseClick/"
var mouse_click_array : Array[AudioStream] = []

const TRANSITION_WOOSH = preload("res://Audio/SFX/TransitionWoosh.wav")
var woosh_array = [TRANSITION_WOOSH]

const TOM_TOM_HIT = preload("res://Audio/SFX/TomTomHit.wav")
var tom_tom_hit_array = [TOM_TOM_HIT]

var synth_pop_folder_path = "res://Audio/SFX/SynthPops/"
var synth_pop_array = []

const DEFEAT_JINGLE = preload("res://Audio/DefeatJingle.wav")
const VICTORY_JINGLE = preload("res://Audio/VictoryJingle.wav")
var jingles = [DEFEAT_JINGLE, VICTORY_JINGLE]

func _ready() -> void:
	Global.audio_controller = self
	
	read_folder_to_array(beep_speech_folder_path, beep_speech_array)
	read_folder_to_array(mouse_click_folder_path, mouse_click_array)
	read_folder_to_array(synth_pop_folder_path, synth_pop_array)

func read_folder_to_array(folder: String, array: Array):
	# Fill beep_speech_array
	var dir := DirAccess.open(folder)
	var file_names := dir.get_files()
	for file_name in file_names:
		if file_name.right(7) != ".import":
			array.append(load(folder + file_name))

func generate_sfx_3d(source: Node3D, sfx_array: Array, gain: float = 0, pitch_min: float = 1, pitch_max: float = pitch_min):
	var audio : AudioStreamPlayer3D = AUDIO_STREAM_3D.instantiate()
	audio.pitch_scale = randf_range(pitch_min, pitch_max)
	audio.volume_db = gain
	audio.stream = sfx_array.pick_random()
	source.add_child(audio)
	audio.play()
	return audio

func generate_sfx_universal(sfx_array: Array, gain: float = 0, pitch_min: float = 1, pitch_max: float = pitch_min) -> AudioStreamPlayer:
	var audio : AudioStreamPlayer = AUDIO_STREAM.instantiate()
	audio.pitch_scale = randf_range(pitch_min, pitch_max)
	audio.volume_db = gain
	audio.stream = sfx_array.pick_random()
	add_child(audio)
	audio.play()
	return audio

func play_jingle(tone: int):
	volume_db = -20
	await generate_sfx_universal([jingles[tone]], -4).finished
	volume_db = -6
	
