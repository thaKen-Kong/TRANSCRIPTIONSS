extends CanvasLayer
class_name RewardScene

# =========================
# DATA FROM GAME_LEVEL
var deliveries_done: int
var deliveries_required: int
var time_left: float
var reward_per_delivery: int

# =========================
# UI NODES
@onready var level_complete: Label = $Control/LEVEL_COMPLETE
@onready var deliveries_label: Label = $Control/DELIVERIES
@onready var atp_label: Label = $Control/DELIVERIES2
@onready var total_label: Label = $Control/DELIVERIES3
@onready var finish_button: Button = $Control/FINISH
@onready var panel: Control = $Control

# =========================
func _ready() -> void:
	# Calculate and display rewards
	_calculate_rewards()

	# Connect button
	finish_button.pressed.connect(_on_finish_pressed)

	# Ensure UI is interactive
	set_process_input(true)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	# Fade in panel (synchronous)
	if Engine.has_singleton("TransitionManager"):
		TransitionManager.fade_in(panel)
	else:
		panel.modulate.a = 1.0  # fallback

# =========================
func _calculate_rewards() -> void:
	var delivery_reward := deliveries_done * reward_per_delivery
	var time_bonus := int(max(time_left, 0))
	var total := delivery_reward + time_bonus

	deliveries_label.text = "DELIVERIES : %d / %d" % [deliveries_done, deliveries_required]
	atp_label.text = "ATP LEFT : %d" % time_bonus
	total_label.text = "TOTAL : %d" % total

# =========================
# Button callback
func _on_finish_pressed() -> void:
	var hub_scene_path = "res://scenes/world/LEVEL/game_area.tscn"

	if Engine.has_singleton("TransitionManager"):
		# Use a signal/callback style for fade-out then scene change
		TransitionManager.fade_out(panel, func():
			get_tree().change_scene_to_file(hub_scene_path)
		)
	else:
		get_tree().change_scene_to_file(hub_scene_path)
