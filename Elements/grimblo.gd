class_name Grimblo extends CharacterBody3D

@onready var cube: GeometryInstance3D = $Character/Player/Cube
@onready var cube_002: GeometryInstance3D = $Character/Player/Cube_002
@onready var cylinder: GeometryInstance3D = $Character/Player/Cylinder
@onready var cube_001: GeometryInstance3D = $Character/Player/Cube_001
@onready var cube_003: MeshInstance3D = $Character/Cube_003
@onready var cube_004: MeshInstance3D = $Character/Cube_004

@onready var pointer: Node3D = $Character/Player/Pointer
@onready var grimbloShapes = [cube, cube_001, cylinder, cube_002]
@onready var grimbloMaterial: Array[Material] = [preload("res://Materials/ActiveGrimblo.tres"), preload("res://Materials/Grimblo.tres"), preload("res://Materials/EnemyGrimblo.tres"), preload("res://Materials/TargetGrimblo.tres")]

@onready var grimbloTieShapes = [cube_003, cube_004]
@onready var grimbloTieMaterial: Array[Material] = [preload("res://Materials/ActiveTie.tres"), preload("res://Materials/PassiveTie.tres"), preload("res://Materials/EnemyTie.tres"), preload("res://Materials/TargetTie.tres")]

@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var label: Label3D = $LabelPivot/Label3D
@onready var close_up: Node3D = $CloseUp # Accessed externally by camera rig

@export_range(0, 2 * PI) var start_dir 
var direction : Vector3
var hasClicked := false
var launchVector : Vector3

@export var activeAlignment : alignment = alignment.PASSIVE

enum alignment { ACTIVE, PASSIVE, ENEMY, TARGET }

var pitch: float
signal done_speaking

@export_flags_3d_physics var LOS_mask

func _ready() -> void:
	direction = Vector3(cos(start_dir), 0, sin(start_dir))
	velocity = direction.normalized() * Global.level.crowd_speed
	set_color()
	
	Global.level.timescale_changed.connect(_update_animation_speed)
	
	pitch = randf_range(.8, 2);

func _update_animation_speed(timescale) -> void:
	animation_player.speed_scale = 2.0 * timescale

func _physics_process(delta: float) -> void:
	if(Global.level.current_game_state == Global.level.game_state.GOLFING and (activeAlignment == alignment.ACTIVE)):
		handle_active_player()
	else:
		handle_passive_player()
	
	if label.visible: label.get_parent().look_at(get_viewport().get_camera_3d().global_position)

func handle_passive_player() -> void:
	var vel := velocity
	velocity *= Global.level.sim_timescale
	move_and_slide()
	# Calculates wall bounce
	var bounced = false
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var dir := vel - 2 * (vel.dot(col.get_normal())) * col.get_normal()
		velocity = dir.normalized() * vel.length()
		bounced = true
	if !bounced:
		velocity = vel
	velocity = velocity.normalized() * lerp(velocity.length(), Global.level.crowd_speed, .02) 
	
	if Global.level.sim_timescale > 0: look_at(position + velocity)

func handle_active_player() -> void:
	animation_player.speed_scale = 0
	if(hasClicked == false && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		hasClicked = true
		Global.level.sim_timescale = .2
		pointer.visible = true
	if(hasClicked == true):
		launchVector = get_mouse_coord() - global_position
		if(!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			velocity = Vector3(launchVector.x, 0, launchVector.z).normalized() * Global.level.crowd_speed * 3
			move_and_slide()
			hasClicked = false
			pointer.visible = false
			Global.level.sim_timescale = 1
			Global.level.current_game_state = Global.level.game_state.DEFAULT
			Global.audio_controller.generate_sfx_3d(self, Global.audio_controller.tom_tom_hit_array, 24, .9, 1.8)
			Global.advanced_stats.increase_par()
		else:
			look_at(global_position + Vector3(launchVector.x, 0, launchVector.z))

func set_color() -> void:
	for shape in grimbloShapes:
		shape.material_override = grimbloMaterial[activeAlignment]
	for tie in grimbloTieShapes:
		tie.material_override = grimbloTieMaterial[activeAlignment]
func say(message: String, letter_speed: float = .05):
	label.text = ""
	label.visible = true
	
	for i in range(message.length()):
		var letter = message[i]
		label.text = label.text + letter
		
		if letter in "aeiouAEIOU!?:":
			var beep = Global.audio_controller.generate_sfx_3d(self, Global.audio_controller.beep_speech_array, 9, pitch)
		
		var real_speed = letter_speed if letter not in ".,!?;:" else .1
		await get_tree().create_timer(real_speed).timeout
	#add a buffer time after the message is done being written
	await get_tree().create_timer(.5).timeout
	
	done_speaking.emit()
	label.visible = false

func can_see(target: Grimblo) -> bool:
	target.set_collision_layer_value(4, true)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, target.global_position, LOS_mask)
	var result = space_state.intersect_ray(query)
	target.set_collision_layer_value(4, false)
	return !result.is_empty() and result.collider == target

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
