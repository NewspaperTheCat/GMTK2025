extends Node

func _to_title():
	Global.game_controller.change_gui_scene("res://Navigation/title.tscn")

func _to_select():
	Global.game_controller.change_gui_scene("WRITE THIS")

func _to_level():
	print("moving to level")
	Global.game_controller.change_3d_scene("res://Navigation/Levels/Level1.tscn")
