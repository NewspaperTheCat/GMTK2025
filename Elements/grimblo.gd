class_name Grimblo extends CharacterBody3D

@onready var cube: GeometryInstance3D = $Character/Player/Cube
@onready var cube_002: GeometryInstance3D = $Character/Player/Cube_002
@onready var cylinder: GeometryInstance3D = $Character/Player/Cylinder
@onready var cube_001: GeometryInstance3D = $Character/Player/Cube_001

@onready var pointer: Node3D = $Character/Player/Pointer
@onready var grimbloShapes = [cube, cube_001, cylinder, cube_002]
@onready var grimbloMaterial: Array[Material] = [preload("res://Materials/ActiveGrimblo.tres"), preload("res://Materials/Grimblo.tres"), preload("res://Materials/EnemyGrimblo.tres"), preload("res://Materials/TargetGrimblo.tres")]

@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer

@export var direction : Vector3
@export var hasMoved := false
var hasClicked := false
var initMousePos : Vector2
var launchVector : Vector2

@export var activeAlignment : alignment = alignment.PASSIVE

enum alignment { ACTIVE, PASSIVE, ENEMY, TARGET }


func _ready() -> void:
	velocity = direction.normalized() * Global.level.crowd_speed
	set_color()

func _process(delta: float) -> void:
	animation_player.speed_scale = 2.0 * Global.level.sim_timescale

func _physics_process(delta: float) -> void:
	if(Global.level.current_game_state == Global.level.game_state.GOLFING and (activeAlignment == alignment.ACTIVE) && !hasMoved):
		handle_active_player()
	else:
		handle_passive_player()

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
	
	look_at(position + velocity)
	
func handle_active_player() -> void:
	if(hasClicked == false && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		hasClicked = true
		initMousePos = get_viewport().get_mouse_position()
		pointer.visible = true
	if(hasClicked == true):
		launchVector = get_viewport().get_mouse_position() - initMousePos
		if(!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			velocity = Vector3(launchVector.x, 0, launchVector.y).normalized() * Global.level.crowd_speed * 1.5
			move_and_slide()
			hasMoved = true
			hasClicked = false
			pointer.visible = false
			Global.level.sim_timescale = 1
			Global.level.current_game_state = Global.level.game_state.DEFAULT
		else:
			look_at(position + Vector3(launchVector.x, 0, launchVector.y))
func set_color() -> void:
	for shape in grimbloShapes:
		shape.material_override = grimbloMaterial[activeAlignment]
