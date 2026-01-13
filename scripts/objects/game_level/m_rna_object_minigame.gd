extends StaticBody2D
class_name mRNA_OBJECT_TRIGGER

@onready var interaction_area: InteractionArea = $InteractionArea
@export var minigame_scene: PackedScene       # BasePairingMinigame scene
@export var box_scene: PackedScene            # The "packaged" box scene

var dna_sequence: String = ""

func _ready() -> void:
	if interaction_area:
		interaction_area.interact = Callable(self, "take_minigame")

# -------------------------
# Launch the minigame
# -------------------------
func take_minigame() -> void:
	if not minigame_scene:
		push_error("No minigame_scene assigned!")
		return

	interaction_area.set_process(false)
	interaction_area.monitoring = false

	var minigame_instance = minigame_scene.instantiate()
	minigame_instance.trigger_object = self
	minigame_instance.dna_sequence = dna_sequence

	get_tree().current_scene.add_child(minigame_instance)

# -------------------------
# Transform trigger into box
# -------------------------
func transform_into_box() -> void:
	if not box_scene:
		push_error("No box_scene assigned!")
		return

	var parent_node = get_parent()  # store parent before transforming
	var box_instance = box_scene.instantiate()
	if box_instance and parent_node:
		parent_node.add_child(box_instance)
		box_instance.global_position = global_position

	if is_inside_tree():
		queue_free()
