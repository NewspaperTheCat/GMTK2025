class_name Grimblo extends CharacterBody3D

@export var direction : Vector3

func _ready() -> void:
	velocity = direction.normalized() * GM.level.crowd_speed

func _physics_process(delta: float) -> void:
	var vel := velocity
	move_and_slide()
	# Calculates wall bounce
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var dir := vel - 2 * (vel.dot(col.get_normal())) * col.get_normal()
		velocity = dir.normalized() * GM.level.crowd_speed
	
	look_at(position + velocity)
