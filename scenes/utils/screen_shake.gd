extends Camera2D
class_name ScreenShake

# ===================
# CONFIG
# ===================
@export var default_magnitude: float = 8.0   # max shake in pixels
@export var default_duration: float = 0.3    # duration in seconds
@export var smoothness: int = 20             # higher = smoother

# ===================
# INTERNAL STATE
# ===================
var shake_time_left: float = 0.0
var shake_magnitude: float = 0.0
var original_offset: Vector2

# ===================
func _ready():
	original_offset = offset

# ===================
func start_shake(magnitude: float = -1, duration: float = -1) -> void:
	shake_magnitude = magnitude if magnitude > 0 else default_magnitude
	shake_time_left = duration if duration > 0 else default_duration

# ===================
func _process(delta: float) -> void:
	if shake_time_left > 0:
		shake_time_left -= delta
		var t = shake_time_left / default_duration
		var damp = t * t  # damping curve for smooth fade-out

		# Random local offset
		offset = original_offset + Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_magnitude * damp
	else:
		offset = original_offset
