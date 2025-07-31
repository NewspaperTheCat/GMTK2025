class_name Player extends Node3D

@onready var loop_indicator: LoopIndicator = $LoopIndicator
@onready var scene_redirect: SceneRedirect = $SceneRedirect

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
			pass_sequence()
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

func pass_sequence():
	var captured = loop_indicator.get_captured()
	if captured.size() < 2:
		return
	
	print("captured a relevant: " + str(captured.size()) + " peeps")
	
	var recipients = []
	var secret_holder = null
	var holds_opp = false
	for i in range(captured.size()):
		if captured[i].activeAlignment == Grimblo.alignment.ENEMY:
			holds_opp = true
		elif captured[i].activeAlignment == Grimblo.alignment.ACTIVE:
			secret_holder = captured[i]
		else:
			recipients.append(captured[i])
	if secret_holder == null:
		return
	if holds_opp:
		print("Whoopsies, GAME OVER")
		return
	
	var chosen_recipient = null
	var to_win = false
	for i in range(recipients.size()):
		if recipients[i].activeAlignment == Grimblo.alignment.TARGET:
			chosen_recipient = recipients[i]
			to_win = true
			break
		elif chosen_recipient == null or chosen_recipient.position.distance_squared_to(secret_holder.position) > recipients[i].position.distance_squared_to(secret_holder.position):
			chosen_recipient = recipients[i]
	
	if to_win:
		print("HUZZAH, you did it!!")
		Global.level_progress = Global.level.level_num
		scene_redirect._to_select()
	else:
		chosen_recipient.activeAlignment = Grimblo.alignment.ACTIVE
		chosen_recipient.set_color()
	secret_holder.activeAlignment = Grimblo.alignment.PASSIVE
	secret_holder.set_color()
	MeshInstance3D
