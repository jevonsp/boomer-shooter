extends Node3D
const MAX_LIFETIME_MS = 5000
var target_pos = Vector3(0,0,0)
var speed = 75.0
var tracer_length = 1
@onready var spawn_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	var dir = (target_pos - Vector3(0.4,0.4,0.4)) - self.global_position
	var add = dir.normalized() * speed * delta
	add = add.limit_length(dir.length())
	global_position += add
	if (target_pos - global_position).length() \
			<= tracer_length or Time.get_ticks_msec() - spawn_time > MAX_LIFETIME_MS:
		queue_free()
