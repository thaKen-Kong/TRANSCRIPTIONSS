extends Node
class_name Cutscene

# =========================
# NODES
# =========================
@onready var cutscene_camera: Camera2D = $Camera2D
@onready var letterbox: LetterBox = $LetterBox

# =========================
# STATE
var steps: Array[Callable] = []
var step_index: int = 0
var is_playing: bool = false
var player_camera: Camera2D = null
var _hidden_ui_layers: Array[CanvasLayer] = []

# =========================
# SIGNALS
signal cutscene_started
signal cutscene_finished
signal step_finished(step_name: String)

# =========================
# PUBLIC API
func play(steps_list: Array[Callable]) -> void:
	if steps_list.is_empty():
		push_warning("Cutscene has no steps.")
		return
	if is_playing:
		return

	_hide_ui()  # hide all CanvasLayer UI

	steps = steps_list
	step_index = 0
	is_playing = true

	_cache_player_camera()
	_switch_to_cutscene_camera()

	emit_signal("cutscene_started")
	letterbox.show_bars()

	_play_next_step()

func stop() -> void:
	if not is_playing:
		return

	is_playing = false
	steps.clear()
	step_index = 0

	letterbox.hide_bars()
	_restore_player_camera()
	_restore_ui()  # restore hidden UI

	emit_signal("cutscene_finished")

# =========================
# INTERNAL FLOW
func _play_next_step() -> void:
	if not is_playing:
		return

	if step_index >= steps.size():
		stop()
		return

	var step: Callable = steps[step_index]
	step_index += 1
	step.call()

func finish_step(step_name: String = "") -> void:
	emit_signal("step_finished", step_name)
	_play_next_step()

# =========================
# CAMERA CONTROL
func _cache_player_camera() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player_camera = player.get_node_or_null("Camera2D")

func _switch_to_cutscene_camera() -> void:
	if player_camera:
		player_camera.enabled = false

	cutscene_camera.enabled = true
	cutscene_camera.make_current()

func _restore_player_camera() -> void:
	cutscene_camera.enabled = false
	if player_camera:
		player_camera.enabled = true
		player_camera.make_current()

# =========================
# UI HIDE/RESTORE
func _hide_ui() -> void:
	_hidden_ui_layers.clear()
	for layer in get_tree().get_nodes_in_group("ui"):
		if layer is CanvasLayer and layer.visible:
			layer.visible = false
			_hidden_ui_layers.append(layer)

func _restore_ui() -> void:
	for layer in _hidden_ui_layers:
		if is_instance_valid(layer):
			layer.visible = true
	_hidden_ui_layers.clear()

# =========================
# CUTSCENE ACTIONS
func focus_on(target: Node2D, duration: float = 0.8) -> void:
	if not target:
		finish_step("focus_invalid")
		return

	var tween := get_tree().create_tween()
	tween.tween_property(
		cutscene_camera,
		"global_position",
		target.global_position,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): finish_step("focus_camera"))

func highlight(target: CanvasItem, duration: float = 1.0) -> void:
	if not target:
		finish_step("highlight_invalid")
		return
	var original: Color = target.modulate
	target.modulate = Color(1, 1, 0)
	await get_tree().create_timer(duration).timeout
	target.modulate = original
	finish_step("highlight")

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	finish_step("wait")

func lock_player(lock: bool) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_input_locked"):
		player.set_input_locked(lock)
