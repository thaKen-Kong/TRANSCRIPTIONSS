extends StaticBody2D
class_name DNA_MT

# =========================
# EXPORTS
# =========================
@export var dna_mission_terminal: PackedScene
@onready var interaction_area: InteractionArea = $InteractionArea

# =========================
# INTERNAL STATE
# =========================
var terminal_instance: Node = null
var is_terminal_open: bool = false

# =========================
# LIFECYCLE
# =========================
func _ready() -> void:
	if interaction_area:
		interaction_area.interact = Callable(self, "toggle_mission_terminal")

# =========================
# TOGGLE TERMINAL
# =========================
func toggle_mission_terminal(player: CharacterBody2D) -> void:
	if not dna_mission_terminal:
		push_error("DNA_MT: No dna_mission_terminal scene assigned!")
		return

	if not is_terminal_open:
		# Instantiate and show the terminal
		terminal_instance = dna_mission_terminal.instantiate()
		add_child(terminal_instance)
		is_terminal_open = true
	else:
		# Close the terminal safely
		if terminal_instance and terminal_instance.is_inside_tree():
			if "close" in terminal_instance:
				terminal_instance.close()  # call a proper method if the scene has one
			else:
				terminal_instance.queue_free()
		is_terminal_open = false
		terminal_instance = null
