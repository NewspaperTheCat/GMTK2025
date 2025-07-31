class_name Player extends Node3D

@onready var path: Path3D = $Line/Path
@onready var camera3d: Camera3D = $Camera3D

var drawing = false
var points := []

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			drawing = true
			start_line(get_mouse_coord())
		else:
			drawing = false
	
	if drawing and event is InputEventMouseMotion:
		add_to_line(get_mouse_coord())

func get_mouse_coord() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var from = camera3d.project_ray_origin(mouse_position)
	var to = from + camera3d.project_ray_normal(mouse_position) * 5
	return to
	#var query = PhysicsRayQueryParameters3D.create(position, position + Vector3(0, -10, 0))
	#var intersect := space_state.intersect_ray(query)
	
	#if intersect.is_empty():
		#return Vector3(0, 11, 0)
	#return intersect.position

func start_line(point: Vector3, color = Color.WHITE_SMOKE):
	path.curve.clear_points()
	path.curve.add_point(point)

func add_to_line(point: Vector3):
	path.curve.add_point(point)
