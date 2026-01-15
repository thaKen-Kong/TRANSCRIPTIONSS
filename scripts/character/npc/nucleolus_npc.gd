extends CharacterBody2D
class_name Nucleolus

# =========================
# NODES
# =========================
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var eye_sprite: Sprite2D = $body/eye
@onready var interaction_area: InteractionArea = $InteractionArea

# =========================
# EXPORTS
# =========================
@export var dialogue: DialogueResource
@export var start_title: String = "start"
@export var game_level: GAME_LEVEL

# =========================
# INTERNAL STATE
# =========================
var node = self
var dialogue_active: bool = false

# =========================
# LIFECYCLE
# =========================
func _ready() -> void:
	GameState.npc = self
	animation_player.play("idle")

	# Assign interaction callback
	if interaction_area:
		interaction_area.interact = Callable(self, "talk")

# =========================
# TALK / INTERACTION
# =========================
func talk(player: Node2D) -> void:
	if dialogue_active:
		return  # Prevent overlapping dialogues

	dialogue_active = true

	# Show dialogue and await completion
	await DialogueManager.show_dialogue_balloon(dialogue)
	dialogue_active = false


# =========================
# START TUTORIAL / GAME LEVEL
# =========================
func _start_level() -> void:
	if game_level:
		game_level.start_level()
