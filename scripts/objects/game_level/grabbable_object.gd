extends RigidBody2D
class_name GrabbableObject

var spawn_location : Vector2
var starting_pos : Vector2

# ======================
# GRAB / CARRY SETTINGS
# ======================
var is_held := false
var holder: Node2D = null

@export var object_tag: String = ""
@export var can_be_grabbed : bool = true
@export var follow_offset := Vector2(0, -32) # hover above player
@export var snap_speed := 10.0               # speed of movement

# ======================
# NODES
# ======================
@onready var sprite: Sprite2D = $Sprite2D

# ======================
# INTERNAL STATE
# ======================
var default_color: Color = Color(1,1,1,1)
var default_scale: Vector2

func _ready():
	if object_tag == "RNA POLYMERASE":
		self.global_position = starting_pos
		print(starting_pos)
		self.global_position.y = starting_pos.y - 2000
	
	if sprite:
		default_color = sprite.modulate
		default_scale = sprite.scale
	
	# Lock rotation
	angular_velocity = 0
	freeze = true

func grab(player: Node2D) -> void:
	if not can_be_grabbed:
		return

	is_held = true
	holder = player
	gravity_scale = 0
	linear_damp = 10
	angular_damp = 10
	rotation = 0
	_update_color()

func drop() -> void:
	is_held = false
	holder = null
	gravity_scale = 0
	linear_damp = 4
	angular_damp = 4
	_update_color()

func _physics_process(delta: float) -> void:
	if is_held and holder != null:
		# ----------------------------
		# Get player height
		# ----------------------------
		var player_height := 0.0
		if holder.has_node("Sprite2D"):
			var player_sprite: Sprite2D = holder.get_node("Sprite2D")
			player_height = player_sprite.texture.get_size().y * player_sprite.scale.y
		elif holder.has_node("CollisionShape2D"):
			var shape = holder.get_node("CollisionShape2D").shape
			if shape is RectangleShape2D:
				player_height = shape.extents.y * 2
			elif shape is CapsuleShape2D:
				player_height = shape.height

		# ----------------------------
		# Get object height
		# ----------------------------
		var object_height := 0.0
		if sprite and sprite.texture:
			object_height = sprite.texture.get_size().y * sprite.scale.y

		# ----------------------------
		# Calculate target position above player
		# ----------------------------
		var overlap_offset := 4.0
		var extra_offset = follow_offset.y
		var target_pos = holder.global_position + Vector2(
			0,
			-player_height / 2 - object_height / 2 + extra_offset + overlap_offset
		)

		# Smoothly move object to target position
		global_position = global_position.lerp(target_pos, snap_speed * delta)

	else:
		# DROPPED: Keep default position
		pass

func _update_color():
	if not sprite:
		return

func _spawn_self():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", spawn_location, 0.4).set_ease(Tween.EASE_OUT)
	await tween.finished
	get_tree().get_first_node_in_group("player").camera.start_shake()
