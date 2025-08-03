class_name AdvancedStats extends VBoxContainer

@onready var speedrun_timer: Label = $SpeedrunTimer
@onready var hit_count: Label = $ParCount

var toggled = false

var scene_time = 0:
	set(value):
		scene_time = value
		speedrun_timer.text = time_convert(scene_time)
var level_par = 0:
	set(value):
		level_par = value
		if Global.level != null:
			hit_count.text = "Par:" + str(Global.level.par) + ", Hits:" + str(level_par)

func _ready() -> void:
	Global.advanced_stats = self
	_on_scene_changed()

func _process(delta: float) -> void:
	scene_time += delta

func _on_scene_changed() -> void:
	visible = toggled and Global.level != null
	scene_time = 0
	level_par = 0

func time_convert(time_in_sec):
	var seconds = int(time_in_sec)%60
	var minutes = (int(time_in_sec)/60)%60
	var milliseconds = int((time_in_sec - seconds) * 100)
	var mstr = str(milliseconds) if milliseconds > 9 else "0" + str(milliseconds)
	return ("%02d:%02d" % [minutes, seconds]) + "." + mstr

func increase_par():
	level_par += 1

func toggle(set_to: bool):
	toggled = set_to
