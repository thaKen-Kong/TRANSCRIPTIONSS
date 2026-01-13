extends State
class_name Move

@onready var player = get_tree().get_first_node_in_group("player")

# =========================
# CONFIG
# =========================
const MAX_ATP_POINTS := 100.0
const DRAIN_PER_SECOND := 50
const TWEEN_DURATION := 0.12

# =========================
# INTERNAL
# =========================
var ui_tween: Tween = null

# =========================
# STATE LIFECYCLE
# =========================
func enter(_entity):
	# Movement handled by entity externally
	_update_energy_ui(true) # instant update on enter

func exit(_entity):
	pass

# =========================
# UPDATE LOOP
# =========================
func update(entity, delta):
	var stats := PlayerInfo.player_info
	var direction := Input.get_vector("a", "d", "w", "s")

	if direction != Vector2.ZERO and stats.atp_units > 0:
		entity.velocity = entity.speed * direction.normalized()
		_drain_atp(delta)
	else:
		entity.velocity = Vector2.ZERO

	if direction == Vector2.ZERO:
		transition_state.emit(self, "idle")

# =========================
# ATP LOGIC
# =========================
func _drain_atp(delta):
	var stats := PlayerInfo.player_info

	stats.atp_points -= DRAIN_PER_SECOND * delta

	if stats.atp_points <= 0:
		stats.atp_units -= 1

		if stats.atp_units > 0:
			stats.atp_points = MAX_ATP_POINTS
		else:
			stats.atp_points = 0

	_update_energy_ui() # update global UI

# =========================
# UI
# =========================
func _update_energy_ui(instant := false):
	var stats := PlayerInfo.player_info

	# Safe reference to global UI nodes
	var bar = player.player_ui.progress_bar
	var label = player.player_ui.label

	if not bar or not label:
		push_warning("ATP UI nodes not found! Make sure 'UI/ATPBar' and 'UI/ATPLabel' exist in scene tree.")
		return

	# Set max value
	bar.max_value = MAX_ATP_POINTS

	# Kill existing tween safely
	if ui_tween and ui_tween.is_valid():
		ui_tween.kill()

	# Tween smooth bar
	if instant:
		bar.value = stats.atp_points
	else:
		ui_tween = get_tree().create_tween()
		ui_tween.tween_property(
			bar,
			"value",
			stats.atp_points,
			TWEEN_DURATION
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Update label
	label.text = str(stats.atp_units)
