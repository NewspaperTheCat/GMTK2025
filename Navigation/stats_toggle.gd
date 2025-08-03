extends Button

func _on_toggled(toggled_on: bool) -> void:
	Global.advanced_stats.toggle(toggled_on)

func _ready() -> void:
	button_pressed = Global.advanced_stats.toggled
