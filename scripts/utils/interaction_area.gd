extends Area2D
class_name InteractionArea

# =========================
# EXPORTED REFERENCES
# =========================
@export var sprite: Sprite2D
@export var label: Label
@export var label_name: String = "Object Name"
@export var action_name: String = "Default Action"

# Interaction callback (assigned externally)
var interact: Callable = Callable()

# =========================
# LIFECYCLE
# =========================
func _ready() -> void:
	# Connect Area2D signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	# Defer initialization to avoid instantiation order issues
	call_deferred("_initialize")

func _exit_tree() -> void:
	# Ensure safe cleanup if this node is freed
	if InteractionManager:
		InteractionManager.unregister_area(self)

# =========================
# INITIALIZATION
# =========================
func _initialize() -> void:
	if not sprite:
		push_warning("InteractionArea: Sprite not assigned.")
	if not label:
		push_warning("InteractionArea: Label not assigned.")
	if label:
		label.text = label_name
		label.hide()
		_update_label_position()

# =========================
# VISUAL FEEDBACK
# =========================
func show_outline(enable: bool) -> void:
	if not sprite or not sprite.material:
		return

	# Make material instance-safe
	if not sprite.material.resource_local_to_scene:
		sprite.material = sprite.material.duplicate()
		sprite.material.resource_local_to_scene = true

	sprite.material.set_shader_parameter("progress", 1.0 if enable else 0.0)

func show_label(enable: bool) -> void:
	if not label:
		return

	if enable:
		_update_label_position()
		label.show()
	else:
		label.hide()

# =========================
# LABEL POSITIONING
# =========================
func _update_label_position() -> void:
	if not sprite or not label or not sprite.texture:
		return

	var sprite_size: Vector2 = sprite.texture.get_size() * sprite.scale
	var top_center: Vector2 = sprite.global_position - Vector2(0, sprite_size.y / 2)

	var label_width: float = label.get_minimum_size().x
	label.global_position = top_center + Vector2(-label_width / 2, -10)

# =========================
# PLAYER PROXIMITY
# =========================
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	InteractionManager.register_area(self)
	show_outline(true)
	show_label(true)

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	InteractionManager.unregister_area(self)
	show_outline(false)
	show_label(false)
