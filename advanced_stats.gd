class_name AdvancedStats extends Control

@onready var in_level_stats: VBoxContainer = $InLevelStats
@onready var speedrun_timer: Label = $InLevelStats/SpeedrunTimer
@onready var hit_count: Label = $InLevelStats/ParCount

@onready var total_stats: VBoxContainer = $TotalStats
@onready var total_timer: Label = $TotalStats/TotalTimer
@onready var total_hits: Label = $TotalStats/TotalHits


var total_time = 0
var total_par = 0

var toggled = false
var stopped = true

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
	if !stopped: scene_time += delta

func stop_timer():
	stopped = true

func _on_scene_changed() -> void:
	in_level_stats.visible = toggled and Global.level != null
	total_stats.visible = toggled and Global.level == null
	stopped = Global.level == null
	
	total_time += scene_time
	total_timer.text = "Total: " + time_convert(total_time)
	
	total_par += level_par
	total_hits.text = "Total Hits: " + str(total_par)
	
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
	total_stats.visible = toggled and Global.level == null
