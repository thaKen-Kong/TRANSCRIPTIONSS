extends Node2D

@onready var label: Label = $CanvasLayer/Label

var base_name: String = "[E] TO "
var active_areas: Array = []
var can_interact: bool = true

# ==========================
# REGISTER / UNREGISTER
# ==========================
func register_area(area: InteractionArea) -> void:
	if area and not active_areas.has(area):
		active_areas.push_back(area)

func unregister_area(area: InteractionArea) -> void:
	if area:
		active_areas.erase(area)

# ==========================
# PROCESS LOOP
# ==========================
func _process(_delta: float) -> void:
	_cleanup_invalid_areas()

	var player_ref := get_tree().get_first_node_in_group("player")
	if not player_ref or not is_instance_valid(player_ref):
		label.hide()
		return

	if active_areas.is_empty() or not can_interact:
		label.hide()
		return

	# Sort areas by distance (closest first)
	active_areas.sort_custom(func(a, b):
		var da = player_ref.global_position.distance_to(a.global_position)
		var db = player_ref.global_position.distance_to(b.global_position)
		if da == db:
			return 0
		return -1 if da < db else 1
	)

	var top_area = active_areas[0]
	if is_instance_valid(top_area):
		label.text = base_name + top_area.action_name
		label.show()
	else:
		label.hide()

# ==========================
# INPUT HANDLING
# ==========================
func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("e"):
		return
	if not can_interact:
		return

	_cleanup_invalid_areas()
	if active_areas.is_empty():
		return

	var area = active_areas[0]
	if not is_instance_valid(area) or not area.interact or not area.interact.is_valid():
		active_areas.erase(area)
		return

	can_interact = false
	label.hide()

	# Call interaction safely
	await _start_interaction(area)

# ==========================
# START INTERACTION
# ==========================
func _start_interaction(area: InteractionArea) -> void:
	if not is_instance_valid(area) or not area.interact or not area.interact.is_valid():
		can_interact = true
		return

	var player_ref := get_tree().get_first_node_in_group("player")

	# Call the interact function. If it is async, this will wait for it automatically
	await area.interact.call(player_ref)

	# Re-enable interaction after it finishes
	can_interact = true

# ==========================
# CLEANUP INVALID AREAS
# ==========================
func _cleanup_invalid_areas() -> void:
	active_areas = active_areas.filter(is_instance_valid)
