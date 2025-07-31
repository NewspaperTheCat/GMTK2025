class_name Player extends Node3D

#@onready var loop_indicator: LoopIndicator = $LoopIndicator
@onready var scene_redirect: SceneRedirect = $SceneRedirect
@onready var shape_cast: ShapeCast3D = $ShapeCast

@export var drawDetail:= 0.5
var drawing = false
var points := []
var pointVisuals := []

const pointVisual = preload("res://art/sphereVisual.tscn")
const DRAW_MAT = preload("res://Materials/drawMat.tres")

func _input(event: InputEvent) -> void:
	if Global.level.current_game_state != Global.level.game_state.DEFAULT:
		end_line()
		return
	
	if event is InputEventMouseButton:
		if event.pressed:
			drawing = true
			start_line(get_mouse_coord())
		else:
			drawing = false
			end_line()
			pass_sequence()
	if drawing and event is InputEventMouseMotion:
		var newPoint = get_mouse_coord()
		if (newPoint.distance_to(points[points.size()-1])) > drawDetail:
			add_to_line(get_mouse_coord())
			create_point_visual(get_mouse_coord())

func end_line():
	for visual in pointVisuals:
		visual.queue_free()
	pointVisuals = []

func create_point_visual(newPoint: Vector3):
	var newPointer = pointVisual.instantiate()
	add_child(newPointer)
	newPointer.global_position = newPoint
	pointVisuals.append(newPointer)

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

func get_texture_coord(world_pos: Vector3):
	return Vector2(world_pos.x, world_pos.z)

func start_line(point: Vector3):
	points.clear()
	points.append(point)

func add_to_line(point: Vector3):
	points.append(point)

func pass_sequence():
	var captured = get_captured()
	if captured.size() < 2:
		return
	
	print("captured a relevant: " + str(captured.size()) + " peeps")
	Global.level.current_game_state = Global.level.game_state.CUTSCENE
	
	var recipients = []
	var secret_holder = null
	var holds_opp = false
	var chosen_recipient = null
	for i in range(captured.size()):
		if captured[i].activeAlignment == Grimblo.alignment.ENEMY:
			holds_opp = true
			chosen_recipient = captured[i]
		elif captured[i].activeAlignment == Grimblo.alignment.ACTIVE:
			secret_holder = captured[i]
		else:
			recipients.append(captured[i])
	if secret_holder == null:
		return
	
	var to_win = false
	if chosen_recipient == null:
		for i in range(recipients.size()):
			if recipients[i].activeAlignment == Grimblo.alignment.TARGET:
				chosen_recipient = recipients[i]
				to_win = true
				break
			elif chosen_recipient == null or chosen_recipient.position.distance_squared_to(secret_holder.position) > recipients[i].position.distance_squared_to(secret_holder.position):
				chosen_recipient = recipients[i]
	
	# Move camera to view the interaction
	Global.level.sim_timescale = 0
	Global.camera_rig.view_interaction(secret_holder.position, chosen_recipient.position)
	await Global.camera_rig.finished_moving
	
	if holds_opp:
		print("Whoopsies, GAME OVER")
		scene_redirect._to_select()
		return
	elif to_win:
		print("HUZZAH, you did it!!")
		Global.level_progress = Global.level.level_num
		scene_redirect._to_select()
	else:
		chosen_recipient.activeAlignment = Grimblo.alignment.ACTIVE
		chosen_recipient.set_color()
	
	secret_holder.activeAlignment = Grimblo.alignment.PASSIVE
	secret_holder.set_color()
	
	#Temp placeholder for cutscene
	await get_tree().create_timer(.8).timeout
	
	# check if we are going to be golfing
	if chosen_recipient.hasMoved:
		Global.camera_rig.return_to_resting()
		Global.level.sim_timescale = 1
		Global.level.current_game_state = Global.level.game_state.DEFAULT
	else:
		Global.camera_rig.return_to_resting()
		Global.level.sim_timescale = .2
		Global.level.current_game_state = Global.level.game_state.GOLFING

func loop_is_closed() -> bool:
	return points.size() > 2 and points[points.size() - 1].distance_to(points[0]) < drawDetail * 10

func get_captured():
	var upa = []
	for k in range(2):
		for i in range(points.size()):
			upa.append(Vector3(points[i].x, k * 6 - 3, points[i].z))
	shape_cast.shape.points = upa
	
	shape_cast.enabled = true
	shape_cast.force_shapecast_update()
	var collided_bodies = []
	for i in shape_cast.get_collision_count():
			collided_bodies.append(shape_cast.get_collider(i))
	shape_cast.enabled = false
	
	print(str(collided_bodies.size()) + " <-- the result")
	return collided_bodies
