class_name Grimblo extends CharacterBody3D

@onready var cube: GeometryInstance3D = $Character/Player/Cube
@onready var cube_002: GeometryInstance3D = $Character/Player/Cube_002
@onready var cylinder: GeometryInstance3D = $Character/Player/Cylinder
@onready var cube_001: GeometryInstance3D = $Character/Player/Cube_001

@onready var grimbloShapes = [cube, cube_001, cylinder, cube_002]
@onready var grimbloMaterial: Array[Material] = [preload("res://Materials/ActiveGrimblo.tres"), preload("res://Materials/Grimblo.tres"), preload("res://Materials/EnemyGrimblo.tres"), preload("res://Materials/TargetGrimblo.tres")]

@export var direction : Vector3
@export var hasMoved := false
@export var activeAlignment : alignment

enum alignment { ACTIVE, PASSIVE, ENEMY, TARGET }


func _ready() -> void:
	velocity = direction.normalized() * GM.level.crowd_speed
	set_color()
	print(activeAlignment)
	

func _physics_process(delta: float) -> void:
	var vel := velocity
	move_and_slide()
	# Calculates wall bounce
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var dir := vel - 2 * (vel.dot(col.get_normal())) * col.get_normal()
		velocity = dir.normalized() * GM.level.crowd_speed
	
	look_at(position + velocity)
	
	if(activeAlignment == 0):
		handle_active_player()
	
func handle_active_player() -> void:
	if(hasMoved):
		null
		
func set_color() -> void:
	for shape in grimbloShapes:
		shape.material_override = grimbloMaterial[activeAlignment]
	
