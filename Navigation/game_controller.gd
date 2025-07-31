class_name GameController extends Node

@onready var world_3d: Node3D = $World3D
@onready var world_2d: Node2D = $World2D
@onready var gui: Control = $GUI
@onready var transition_controller: TransitionController = $TransitionController

var current_3d_scene
var current_2d_scene
var current_gui_scene

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = $GUI/Title

func change_gui_scene(new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = true,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
	seconds: float = 1.0
) -> void:
	if transition:
		transition_controller.transition(transition_out, seconds)
		await transition_controller.animation_player.animation_finished
	
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	
	transition_controller.transition(transition_in, seconds)

func change_2d_scene(new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = true,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
	seconds: float = 1.0
) -> void:
	if transition:
		transition_controller.transition(transition_out, seconds)
		await transition_controller.animation_player.animation_finished
	
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.visible = false
		else:
			gui.remove_child(current_2d_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_2d_scene = new
	
	transition_controller.transition(transition_in, seconds)

func change_3d_scene(new_scene: String,
	delete: bool = true,
	keep_running: bool = false,
	transition: bool = true,
	transition_in: String = "Fade In",
	transition_out: String = "Fade Out",
	seconds: float = 1.0
) -> void:
	if transition:
		transition_controller.transition(transition_out, seconds)
		await transition_controller.animation_player.animation_finished
	
	if current_3d_scene != null:
		if delete:
			current_3d_scene.queue_free()
		elif keep_running:
			current_3d_scene.visible = false
		else:
			gui.remove_child(current_3d_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_3d_scene = new
	
	transition_controller.transition(transition_in, seconds)
