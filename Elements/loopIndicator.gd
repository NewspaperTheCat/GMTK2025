class_name LoopIndicator extends Node3D

var indicator_scale = 1.0

@onready var ring: MeshInstance3D = $Ring
@onready var fill: MeshInstance3D = $Fill
@onready var detector: ShapeCast3D = $Detector

func scale_up(delta: float) -> void:
	scale_to(indicator_scale + delta)

func scale_to(to: float):
	indicator_scale = to
	ring.mesh.inner_radius = .625 * to
	ring.mesh.outer_radius = .625 * to + .175
	fill.mesh.bottom_radius = .625 * to + .0875
	detector.shape.radius = .625 * to

func reset_scale():
	scale_to(1)

func get_radius():
	return ring.mesh.inner_radius

func _physics_process(delta: float) -> void:
	if detector.is_colliding():
		for i in detector.get_collision_count():
			var body = detector.get_collider(i)

func get_captured():
	var collided_bodies = []
	for i in detector.get_collision_count():
			collided_bodies.append(detector.get_collider(i))
	return collided_bodies
