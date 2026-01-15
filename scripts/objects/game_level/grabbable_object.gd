extends RigidBody2D
class_name GrabbableObject

# ======================
# GRAB / CARRY SETTINGS
# ======================
var is_held := false
var holder: Node2D = null
var near_dropplace: DropPlace = null
var snapping_to_drop := false

@export var object_tag: String = ""
@export var can_be_grabbed := true
@export var follow_offset := Vector2(0, -32)
@export var snap_speed := 10.0
@export var place_speed := 8.0

# ======================
# NODES
# ======================
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: InteractionArea = $InteractionArea

# ======================
# INTERNAL STATE
# ======================
var default_color := Color.WHITE
var default_scale := Vector2.ONE

# ======================
# LIFECYCLE
# ======================
func _ready() -> void:
	if sprite:
		default_color = sprite.modulate
		default_scale = sprite.scale

	# Physics setup
	gravity_scale = 0
	linear_damp = 4
	angular_damp = 4
	freeze = true
	angular_velocity = 0

	# Interaction setup
	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact_with_player")
		interaction_area.label_name = object_tag
		interaction_area.action_name = "Grab"
		interaction_area.show_label(true)
		interaction_area.show_outline(true)
		interaction_area.monitoring = true
		interaction_area.monitorable = true

func _exit_tree() -> void:
	if interaction_area:
		InteractionManager.unregister_area(interaction_area)

# ======================
# INTERACTION CALLBACK
# ======================
func _on_interact_with_player(player: Node2D) -> void:
	if not can_be_grabbed:
		return

	if near_dropplace:
		_place_on_drop()
		return

	if is_held:
		drop()
	else:
		grab(player)

# ======================
# GRAB / DROP LOGIC
# ======================
func grab(player: Node2D) -> void:
	if not player:
		return

	is_held = true
	holder = player
	snapping_to_drop = false

	# Disable physics influence while held
	gravity_scale = 0
	linear_damp = 10
	angular_damp = 10
	rotation = 0

	_update_color()

	if interaction_area:
		interaction_area.action_name = "Drop"
		interaction_area.show_label(true)

func drop() -> void:
	is_held = false
	holder = null
	snapping_to_drop = false

	# Restore physics
	gravity_scale = 0
	linear_damp = 4
	angular_damp = 4

	_update_color()

	if interaction_area:
		interaction_area.action_name = "Grab"
		interaction_area.show_label(true)

func _place_on_drop() -> void:
	is_held = false
	holder = null
	snapping_to_drop = true

	if interaction_area:
		interaction_area.action_name = "Grab"

# ======================
# PHYSICS
# ======================
func _physics_process(delta: float) -> void:
	if is_held and holder:
		_follow_holder(delta)

	if snapping_to_drop and near_dropplace:
		_snap_to_drop(delta)

func _follow_holder(delta: float) -> void:
	if not holder:
		return

	var player_height := 0.0
	if holder.has_node("Sprite2D"):
		var s: Sprite2D = holder.get_node("Sprite2D")
		if s.texture:
			player_height = s.texture.get_size().y * s.scale.y

	var object_height := 0.0
	if sprite and sprite.texture:
		object_height = sprite.texture.get_size().y * sprite.scale.y

	var target_pos := holder.global_position + Vector2(
		0,
		-player_height / 2 - object_height / 2 + follow_offset.y + 4
	)

	global_position = global_position.lerp(target_pos, snap_speed * delta)

func _snap_to_drop(delta: float) -> void:
	global_position = global_position.lerp(
		near_dropplace.global_position,
		place_speed * delta
	)

	if global_position.distance_to(near_dropplace.global_position) < 1.0:
		snapping_to_drop = false

		if near_dropplace.has_signal("object_placed"):
			near_dropplace.emit_signal("object_placed", self)

		_set_interaction_layer_to_slot_5()
		near_dropplace = null

# ======================
# VISUALS
# ======================
func _update_color() -> void:
	if sprite:
		sprite.modulate = default_color

# ======================
# POST-DELIVERY COLLISION LAYER
# ======================
func _set_interaction_layer_to_slot_5() -> void:
	if interaction_area:
		interaction_area.collision_layer = 0
		interaction_area.set_collision_layer_value(5, true)
		interaction_area.monitoring = false
		interaction_area.monitorable = false
		InteractionManager.unregister_area(interaction_area)
