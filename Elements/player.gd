class_name Player extends Node3D

#@onready var loop_indicator: LoopIndicator = $LoopIndicator
@onready var scene_redirect: SceneRedirect = $SceneRedirect
@onready var shape_cast: ShapeCast3D = $ShapeCast

@export var drawDetail:= 0.5
@export var maxDrawRadius := 1.5
var drawing = false
var points := []
var pointVisuals := []

const pointVisual = preload("res://art/sphereVisual.tscn")
const DRAW_MAT = preload("res://Materials/drawMat.tres")

func _input(event: InputEvent) -> void:
	if Global.level.current_game_state != Global.level.game_state.DEFAULT:
		end_line()
		return
	
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			drawing = true
			start_line(get_mouse_coord())
		elif drawing:
			drawing = false
			end_line()
			pass_sequence()
	if drawing and event is InputEventMouseMotion:
		var newPoint = get_mouse_coord()
		#if points[0].distance_to(newPoint) > maxDrawRadius:
			#newPoint = points[0] + (newPoint - points[0]).normalized() * maxDrawRadius
		if (newPoint.distance_to(points[points.size()-1])) > drawDetail:
			add_to_line(newPoint)
			create_point_visual(newPoint)
	
	if event is InputEventMouseButton and event.button_index == 2 and drawing:
		drawing = false
		end_line()
		points = []

func end_line():
	for visual in pointVisuals:
		visual.queue_free()
	pointVisuals = []

func create_point_visual(newPoint: Vector3):
	var newPointer = pointVisual.instantiate()
	add_child(newPointer)
	newPointer.global_position = newPoint
	pointVisuals.append(newPointer)
	Global.audio_controller.generate_sfx_3d(newPointer, Global.audio_controller.synth_pop_array, -15, .7, 1.5)

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
	
	Global.level.hide_tutorial()
	
	var recipients = []
	var secret_holder = null
	var holds_opp = false
	var chosen_recipient = null
	for i in range(captured.size()):
		if captured[i].activeAlignment == Grimblo.alignment.ACTIVE:
			secret_holder = captured[i]
		else:
			recipients.append(captured[i])
	
	if secret_holder == null:
		return
	
	var to_win = false
	for i in range(recipients.size()):
		if not secret_holder.can_see(recipients[i]):
			continue
		# CHECK LINE OF SIGHT HERE TODO
		
		if recipients[i].activeAlignment == Grimblo.alignment.ENEMY:
			holds_opp = true
			chosen_recipient = recipients[i]
			break
		if recipients[i].activeAlignment == Grimblo.alignment.TARGET:
			chosen_recipient = recipients[i]
			to_win = true
		elif (chosen_recipient == null or chosen_recipient.position.distance_squared_to(secret_holder.position) > recipients[i].position.distance_squared_to(secret_holder.position)) and !to_win:
			chosen_recipient = recipients[i]
	
	if chosen_recipient == null:
		return
	Global.level.current_game_state = Global.level.game_state.CUTSCENE
	
	# Tell grimblos to look at each other
	chosen_recipient.look_at(secret_holder.global_position)
	secret_holder.look_at(chosen_recipient.global_position)
	
	# Move camera to view the interaction
	Global.level.sim_timescale = 0
	Global.camera_rig.view_interaction(secret_holder.global_position, chosen_recipient.global_position)
	await Global.camera_rig.finished_moving
	
	var openers = ["Keep quiet about this", "Between you and me", "Don't tell anyone", "On the down low", "Psst, hey", "Codeword: Grimblo", "Pass this along"]
	var dialogue: Array[String]
	var close_up_index = -1
	var jingle = -1
	var result: int # 0 = pass ; 1 = win ; 2 = lose
	
	if holds_opp:
		result = 2
		var enemy_responses := ["You don't say >:)", "The world needs to know", "I'm a bit of a blabbermouth", "You're so busted"]
		dialogue = [openers.pick_random(), enemy_responses.pick_random(), "uh oh...", "HEY EVERYONE!!"]
		close_up_index = 3
		jingle = 0
	elif to_win:
		result = 1
		var victory_openers = ["A little birdy told me...", "I got something for you", "Did you know"]
		var victory_responses = ["!!!!!", "No. Way!!", "The whole time!?", "Inconceivable!"]
		dialogue = [victory_openers.pick_random(), victory_responses.pick_random()]
		close_up_index = 1
		jingle = 1
	else:
		result = 0
		var neutral_responses = ["Safe with me", "Not a word", "Lips are sealed", "Aye aye, captain", "Roger that", "Silent as the night"]
		dialogue = [openers.pick_random(), neutral_responses.pick_random()]
	
	await play_dialogue(secret_holder, chosen_recipient, dialogue, close_up_index, jingle)
	
	if result == 0:
		chosen_recipient.activeAlignment = Grimblo.alignment.ACTIVE
		chosen_recipient.set_color()
		secret_holder.activeAlignment = Grimblo.alignment.PASSIVE
		secret_holder.set_color()
		
		Global.audio_controller.generate_sfx_3d(chosen_recipient, Global.audio_controller.active_swapped_array, -4)
		await get_tree().create_timer(.3).timeout
		
		Global.camera_rig.return_to_resting()
		Global.level.sim_timescale = 1
		Global.level.current_game_state = Global.level.game_state.GOLFING
	elif result == 1:
		Global.level_progress = Global.level.level_num
		Global.game_controller.show_victory()
	elif result == 2:
		scene_redirect._to_level(Global.level.level_num)

func play_dialogue(initiator: Grimblo, recipient: Grimblo, transcript: Array[String], close_up_index: int = -1, jingle = -1):
	var speaker: Grimblo
	for i in range(transcript.size()):
		speaker = initiator if i % 2 == 0 else recipient
		if i == close_up_index:
			Global.camera_rig.close_up(speaker)
			if jingle > -1: Global.audio_controller.play_jingle(jingle)
		speaker.say(transcript[i])
		await speaker.done_speaking

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
	
	return collided_bodies
