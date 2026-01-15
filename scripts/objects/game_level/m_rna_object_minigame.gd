extends StaticBody2D
class_name mRNA_OBJECT_TRIGGER

# =========================
# NODES & REFERENCES
# =========================
@onready var interaction_area: InteractionArea = $InteractionArea
@export var minigame_scene: PackedScene       # BasePairingMinigame scene
@export var box_scene: PackedScene            # The "packaged" box scene

# DNA sequence to pass to the minigame
var dna_sequence: String = ""

# =========================
# LIFECYCLE
# =========================
func _ready() -> void:
	if interaction_area:
		# Assign the interaction callback
		interaction_area.interact = Callable(self, "take_minigame")

# =========================
# LAUNCH THE MINIGAME
# =========================
func take_minigame(player: Node2D) -> void:
	if not minigame_scene:
		push_error("mRNA_OBJECT_TRIGGER: No minigame_scene assigned!")
		return

	# Disable interaction while minigame is active
	if interaction_area:
		interaction_area.monitoring = false
		interaction_area.set_process(false)

	# Instantiate minigame
	var minigame_instance = minigame_scene.instantiate()
	minigame_instance.trigger_object = self
	minigame_instance.dna_sequence = dna_sequence

	# Add to current scene
	get_tree().current_scene.add_child(minigame_instance)

# =========================
# TRANSFORM INTO BOX
# =========================
func transform_into_box() -> void:
	if not box_scene:
		push_error("mRNA_OBJECT_TRIGGER: No box_scene assigned!")
		return

	var parent_node = get_parent()
	if not parent_node:
		return

	# Instantiate box
	var box_instance = box_scene.instantiate()
	if box_instance:
		parent_node.add_child(box_instance)
		box_instance.global_position = global_position

	# Remove the trigger
	if is_inside_tree():
		queue_free()
