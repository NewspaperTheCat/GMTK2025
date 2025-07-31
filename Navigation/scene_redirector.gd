class_name SceneRedirect extends Node

func _to_title():
	Global.game_controller.change_gui_scene("res://Navigation/title.tscn")
	Global.game_controller.change_3d_scene("blank")

func _to_select():
	Global.game_controller.change_gui_scene("res://Navigation/level_select.tscn")
	Global.game_controller.change_3d_scene("blank")

func _to_level(lvl: int = 1):
	print("moving to level")
	Global.game_controller.change_3d_scene("res://Navigation/Levels/Level" + str(lvl) + ".tscn")
	Global.game_controller.change_gui_scene("blank")
