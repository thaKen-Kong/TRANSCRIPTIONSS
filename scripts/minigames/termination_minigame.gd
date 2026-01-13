extends CanvasLayer
class_name TerminationMinigame

signal termination_complete(success: bool)

# --------------------------
# CONFIG
@export var fill_per_click: float = 3.3
@export var decay_per_second: float = 10.0
@export var max_value: float = 100.0
@export var duration: float = 10.0
@export var atp_reduction: int = 6

@export var green_screen: PackedScene
@export var red_screen: PackedScene

@export var pulse_scale: float = 1.2
@export var pulse_duration: float = 0.1

# --------------------------
# STATE
var current_value: float = 0.0
var remaining_time: float = 0.0
var game_active: bool = false
var timer_started: bool = false
var button_held: bool = false

# --------------------------
# NODES
@onready var base_container : Control = $Control
@onready var progress_bar: TextureProgressBar = $Control/CONTAINER/ProgressBar
@onready var mash_button: Button = $Control/CONTAINER/Button
@onready var timer_label: Label = $Control/CONTAINER/Timer
@onready var atp_label: Label = $Control/CONTAINER/Label
@onready var termination_visual: Sprite2D = $Control/CONTAINER/TeminationVisual

# --------------------------
func _ready():
	_reset_minigame()
	mash_button.pressed.connect(_on_button_pressed)
	_open()

# --------------------------
func _unhandled_input(event):
	var input_ok = false

	# Keyboard input
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept") and not button_held:
			button_held = true
			input_ok = true
		elif event.is_action_released("ui_accept"):
			button_held = false
			_reset_visual_scale()

	# Mouse input
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not button_held:
			button_held = true
			input_ok = true
		elif not event.is_pressed():
			button_held = false
			_reset_visual_scale()

	if input_ok:
		_start_timer_if_needed()
		_increment_fill()
		_scale_up_visual()

# --------------------------
func _process(delta):
	if not game_active:
		return

	# Timer countdown
	if timer_started:
		remaining_time -= delta
		if remaining_time <= 0:
			remaining_time = 0
			_fail_game()
		_update_timer_label()

	# Progress bar decay
	if current_value > 0:
		current_value = max(current_value - decay_per_second * delta, 0)
		progress_bar.value = current_value
		
	if progress_bar.value / max_value > 0.7:
	# Pulse the termination_visual slightly red
		termination_visual.modulate = Color(1, 0.8, 0.8) # slight red tint
	else:
		termination_visual.modulate = Color(1, 1, 1) # normal

# --------------------------
func _update_timer_label():
	timer_label.text = "Time: %0.1fs" % remaining_time

func _update_atp_label():
	atp_label.text = "ATP: %d" % PlayerInfo.player_info.atp_units

# --------------------------
func _on_button_pressed():
	if not button_held:
		button_held = true
		_start_timer_if_needed()
		_increment_fill()
		_scale_up_visual()

# --------------------------
func _start_timer_if_needed():
	if not timer_started:
		timer_started = true
		game_active = true
		remaining_time = duration
		_update_timer_label()

# --------------------------
# New helper: scales fill based on how full the bar is
func _get_scaled_fill() -> float:
	# Linear decrease: last 30% of the bar is harder to fill
	var fraction = current_value / max_value
	var scale_factor = 1.0 - (fraction * 0.08) # Early: full speed, late: ~30% weaker
	return fill_per_click * scale_factor

# --------------------------
func _increment_fill():
	if not game_active:
		return

	# Apply scaled fill
	var scaled_fill = _get_scaled_fill()
	current_value += scaled_fill

	if current_value >= max_value:
		current_value = max_value
		progress_bar.value = current_value
		_success_game()
	else:
		progress_bar.value = current_value

# --------------------------
func _success_game():
	game_active = false
	timer_started = false
	timer_label.text = "TERMINATED SUCCESSFULLY"
	emit_signal("termination_complete", true)

	if green_screen:
		var green_instance = green_screen.instantiate()
		add_child(green_instance)
	await get_tree().create_timer(1).timeout
	_close()
	await get_tree().create_timer(1).timeout
	queue_free()

# --------------------------
func _fail_game():
	game_active = false
	timer_started = false
	timer_label.text = "FAILED! TRY AGAIN"

	# Deduct ATP
	PlayerInfo.player_info.atp_units = max(PlayerInfo.player_info.atp_units - atp_reduction, 0)
	_update_atp_label()
	emit_signal("termination_complete", false)

	# Show red screen
	if red_screen:
		var red_instance = red_screen.instantiate()
		add_child(red_instance)

	# Reset after short delay
	await get_tree().create_timer(1).timeout
	_reset_minigame()

# --------------------------
func _reset_minigame():
	current_value = 0
	progress_bar.value = current_value
	remaining_time = duration
	game_active = false
	timer_started = false
	button_held = false
	timer_label.text = "PRESS SPACE TO START"
	_update_atp_label()
	_reset_visual_scale()

# --------------------------
func _scale_up_visual():
	var tw = create_tween()
	tw.tween_property(termination_visual, "scale", Vector2.ONE * pulse_scale, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.play()

func _reset_visual_scale():
	var tw = create_tween()
	tw.tween_property(termination_visual, "scale", Vector2.ONE, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.play()

# --------------------------
func _close():
	var tween = get_tree().create_tween()
	tween.tween_property(base_container, "global_position", Vector2(0, 20), 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(base_container, "global_position", Vector2(0, -1000), 0.5).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()

func _open():
	base_container.global_position = Vector2(0, -1000)
	var tween = get_tree().create_tween()
	tween.tween_property(base_container, "global_position", Vector2(0, 20), 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(base_container, "global_position", Vector2(0, 0), 0.2).set_ease(Tween.EASE_IN_OUT)
