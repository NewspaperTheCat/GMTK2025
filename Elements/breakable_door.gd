extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var static_body_3d: StaticBody3D = $StaticBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var break_margin = 1.75

func _on_grimblo_entered(body: Grimblo) -> void:
	if body.velocity.length() > Global.level.crowd_speed * break_margin:
		break_door()
	elif body.activeAlignment == body.alignment.ACTIVE:
		await get_tree().create_timer(.1).timeout
		Global.audio_controller.generate_sfx_3d(self, Global.audio_controller.door_thump_array, 0, .8, 1.4)
		

func break_door():
	Global.audio_controller.generate_sfx_3d(self, Global.audio_controller.door_burst_array, 0, 1, 1.6)
	area_3d.collision_mask = 0
	static_body_3d.collision_layer = 0
	animation_player.play("door_open")
