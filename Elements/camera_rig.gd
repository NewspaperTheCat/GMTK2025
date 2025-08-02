class_name CameraRig extends Path3D

@export var camera_move_duration = .75;
@export var camera_velocity_curve : Curve
@export var camera_follow_extent = .85;

@onready var follow: PathFollow3D = $PathFollow
@onready var camera: Camera3D = $PathFollow/Camera3D

var resting_pos : Vector3
var resting_rot : Vector3

var moving := false
var move_dir = 1
var timer := 0.0
var target_rot : Vector3

signal finished_moving

func _ready() -> void:
	Global.camera_rig = self
	resting_pos = camera.global_position
	resting_rot = camera.global_rotation

func view_interaction(initiator_pos: Vector3, recipient_pos: Vector3):
	var perp_dir = recipient_pos - initiator_pos
	var center = initiator_pos + perp_dir / 2
	
	var in_dir = perp_dir.cross(Vector3.UP).normalized() * 6
	if (-in_dir).dot(Vector3.FORWARD) < in_dir.dot(Vector3.FORWARD):
		in_dir *= -1
	
	var curve = Curve3D.new()
	curve.add_point(resting_pos, Vector3.ZERO, Vector3(0, -3, 0))
	curve.add_point(center, in_dir)
	self.curve = curve
	
	follow.progress_ratio = camera_follow_extent
	camera.look_at(center)
	target_rot = camera.global_rotation
	camera.global_rotation = resting_rot
	follow.progress_ratio = 0
	
	timer = 0.001
	moving = true
	move_dir = 1

func close_up(target: Grimblo):
	camera.near = .3
	#var curve = Curve3D.new()
	#curve.add_point(target.close_up.global_position)
	#curve.add_point(camera.global_position, Vector3.ZERO, Vector3(0, 2, 0))
	#self.curve = curve
	#target_rot = target.close_up.global_rotation
	#resting_rot = camera.global_rotation
	
	#moving = true
	#move_dir = -1
	
	camera.global_position = target.close_up.global_position
	camera.look_at(target.global_position + Vector3.UP * target.close_up.position.y)

func return_to_resting():
	camera.near = 1
	
	self.curve.set_point_position(0, resting_pos)
	self.curve.set_point_in(0, Vector3.ZERO)
	self.curve.set_point_out(0, Vector3(0, -3, 0))
	
	moving = true
	move_dir = -1

func _process(delta: float) -> void:
	if moving:
		timer += delta * move_dir
		follow.progress_ratio = camera_velocity_curve.sample(timer / camera_move_duration) * camera_follow_extent
		if timer >= camera_move_duration or timer <= 0:
			follow.progress_ratio = clampf(follow.progress_ratio, 0, camera_follow_extent)
			moving = false
			finished_moving.emit()
		
		camera.global_rotation = lerp(resting_rot, target_rot, timer / camera_move_duration)
