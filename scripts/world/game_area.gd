extends Node2D

@export var player: Player

@onready var area: Area2D = $UI_ACTIVATION

func _ready():
	# Disable all collision shapes at start
	for child in area.get_children():
		if child is CollisionShape2D:
			child.disabled = true

	# Enable them after 1 second
	call_deferred("_enable_area_shapes")

	# Check if player is already inside the area
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			_on_ui_activation_body_entered(body)

# =========================
# ENABLE AREA AFTER DELAY
# =========================
func _enable_area_shapes() -> void:

	for child in area.get_children():
		if child is CollisionShape2D:
			child.disabled = false

# =========================
# SIGNAL CALLBACK
# =========================
func _on_ui_activation_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Hide player UI and disable ATP drain
		if body.player_ui:
			body.player_ui.hide()
		PlayerInfo.player_info.atp_drain_enabled = false
