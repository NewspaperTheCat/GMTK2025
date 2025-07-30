class_name Player extends Node

@onready var line_mesh: MeshInstance3D = $LineMesh

var drawing = false
var points := []

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		drawing = event.pressed
		start_line(Vector3(0, 3, 0))
	
	if drawing and event is InputEventMouseMotion:
		pass

func start_line(point:Vector3, color = Color.WHITE_SMOKE):
	var immediate_mesh := ImmediateMesh.new()
	points = [point]
	var material := ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	line_mesh.mesh = immediate_mesh
	line_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(point)
	immediate_mesh.surface_end()

func add_to_line(point:Vector3) :
	var immediate_mesh := ImmediateMesh.new()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, line_mesh.mesh.surface_get_material(0))
	points.append(point)
	for i in range(points.size()):
		immediate_mesh.surface_add_vertex(points[i])
	immediate_mesh.surface_end()
