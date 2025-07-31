class_name Player extends Node3D

@onready var loop_indicator: LoopIndicator = $LoopIndicator

var drawing = false
var points := []

func _process(delta: float) -> void:
	loop_indicator.position = get_mouse_coord()
	
	if Input.is_mouse_button_pressed(1):
		drawing = true
		loop_indicator.scale_up(delta)
	elif drawing:
		drawing = false
		if get_mouse_coord().y == 11:
			loop_indicator.reset_scale()
		else:
			pass
			#initiate swap scan/sequence
			loop_indicator.reset_scale()

func get_mouse_coord() -> Vector3:
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var camera = viewport.get_camera_3d()

	var origin = camera.project_ray_origin(mouse_position)
	var direction = camera.project_ray_normal(mouse_position)

	var ray_length = camera.far
	var end = origin + direction * ray_length

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end, 2)
	var result = space_state.intersect_ray(query)
	
	# The default vector is an edge case that means we found nothing
	var mouse_position_3D: Vector3 = result.get("position", Vector3(0, 11, 0))
	
	return mouse_position_3D

#func find_captured_grimblos():
	#var radius = loop_indicator.get_radius()
	#
	#ShapeCast3D
	#if shape_cast.is_colliding():
	#for i in shape_cast.get_collision_count():
		#var body = shape_cast.get_collider(i)
		#if body.is_in_group("Enemy"): print("It`s Enemy, Kill Him!")
