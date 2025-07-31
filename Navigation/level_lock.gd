extends Button

@export var level_num : int

func _ready() -> void:
	if level_num > Global.level_progress + 1:
		modulate = Color.GRAY
		disabled = true
	else:
		modulate = Color.WHITE
		disabled = false
