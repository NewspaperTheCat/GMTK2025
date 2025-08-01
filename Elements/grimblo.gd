class_name Grimblo extends CharacterBody3D

@onready var cube: GeometryInstance3D = $Character/Player/Cube
@onready var cube_002: GeometryInstance3D = $Character/Player/Cube_002
@onready var cylinder: GeometryInstance3D = $Character/Player/Cylinder
@onready var cube_001: GeometryInstance3D = $Character/Player/Cube_001

@onready var pointer: Node3D = $Character/Player/Pointer
@onready var grimbloShapes = [cube, cube_001, cylinder, cube_002]
@onready var grimbloMaterial: Array[Material] = [preload("res://Materials/ActiveGrimblo.tres"), preload("res://Materials/Grimblo.tres"), preload("res://Materials/EnemyGrimblo.tres"), preload("res://Materials/TargetGrimblo.tres")]

@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer
@onready var label: Label3D = $LabelPivot/Label3D

@export var direction : Vector3
var hasClicked := false
var initMousePos : Vector2
var launchVector : Vector2

@export var activeAlignment : alignment = alignment.PASSIVE

enum alignment { ACTIVE, PASSIVE, ENEMY, TARGET }

signal done_speaking

func _ready() -> void:
	velocity = direction.normalized() * Global.level.crowd_speed
	set_color()
	
	Global.level.timescale_changed.connect(_update_animation_speed)

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
	if(hasClicked == false && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		hasClicked = true
		initMousePos = get_viewport().get_mouse_position()
		Global.level.sim_timescale = .2
		pointer.visible = true
	if(hasClicked == true):
		launchVector = get_viewport().get_mouse_position() - initMousePos
		if(!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			velocity = Vector3(launchVector.x, 0, launchVector.y).normalized() * Global.level.crowd_speed * 1.5
			move_and_slide()
			hasClicked = false
			pointer.visible = false
			Global.level.sim_timescale = 1
			Global.level.current_game_state = Global.level.game_state.DEFAULT
		else:
			look_at(position + Vector3(launchVector.x, 0, launchVector.y))
func set_color() -> void:
	for shape in grimbloShapes:
		shape.material_override = grimbloMaterial[activeAlignment]

func say(message: String, letter_speed: float = .05):
	label.text = ""
	label.visible = true
	
	for i in range(message.length()):
		label.text = label.text + message[i]
		await get_tree().create_timer(letter_speed).timeout
	#add a buffer time after the message is done being written
	await get_tree().create_timer(.4).timeout
	
	done_speaking.emit()
	label.visible = false
