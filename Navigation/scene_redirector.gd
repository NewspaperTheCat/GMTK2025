class_name SceneRedirect extends Node

func _to_title():
	Global.game_controller.change_scene("res://Navigation/title.tscn")

func _to_select():
	Global.game_controller.change_scene("res://Navigation/level_select.tscn")

func _to_level(lvl: int):
	Global.game_controller.change_scene("res://Navigation/Levels/Level" + str(lvl) + ".tscn")
