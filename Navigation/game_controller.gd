class_name GameController extends Node

@onready var world = $World
@onready var transition_controller: TransitionController = $TransitionController

var current_scene
signal scene_changed

func _ready() -> void:
	Global.game_controller = self
	current_scene = $World/Title

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		Global.audio_controller.generate_sfx_universal(Global.audio_controller.mouse_click_array, -12, .5, 1.5)

func change_scene(
	new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = true,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
) -> void:
	if transition:
		transition_controller.transition(transition_out)
		await transition_controller.animation_player.animation_finished
	
	if current_scene != null:
		if delete:
			current_scene.queue_free()
		elif keep_running:
			current_scene.visible = false
		else:
			world.remove_child(current_scene)
	if new_scene != "blank":
		var new = load(new_scene).instantiate()
		world.add_child(new)
		current_scene = new
		if "Level" not in new_scene:
			Global.level = null
		scene_changed.emit()
	
	if transition: transition_controller.transition(transition_in)
