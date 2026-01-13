# TransitionManager.gd
extends CanvasLayer

@export var fade_duration := 1.0
var _fade_rect: ColorRect
var _is_transitioning := false

func _ready():
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 0.0
	_fade_rect.size = get_viewport().get_visible_rect().size
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)
	get_viewport().size_changed.connect(_on_viewport_resized)

func _on_viewport_resized():
	_fade_rect.size = get_viewport().get_visible_rect().size

# ----------------------------
# Public interface
func fade_in_async() -> void:
	await _fade_in()

func fade_out_async() -> void:
	await _fade_out()

func change_scene(scene_path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade_out()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	var new_scene := get_tree().current_scene
	if new_scene:
		await new_scene.ready
	await _fade_in()
	_is_transitioning = false

# ----------------------------
# Internal
func _fade_out() -> void:
	_fade_rect.visible = true
	_fade_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
