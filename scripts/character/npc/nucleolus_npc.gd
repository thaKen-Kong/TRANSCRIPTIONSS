extends CharacterBody2D
class_name Nucleolus

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var eye_sprite : Sprite2D = $body/eye
@onready var interaction_area : InteractionArea = $InteractionArea

@export var dialogue: DialogueResource
@export var start_title: String = "start"

@export var game_level : GAME_LEVEL


var node = self

func _ready():
	GameState.npc = self
	animation_player.play("idle")
	interaction_area.interact = Callable(self, "talk")

func talk():
	# Start tutorial dialogue
	DialogueManager.show_dialogue_balloon(dialogue)

func _on_dialogue_complete():
	# After dialogue, start tutorial
	_start_level()

func _start_level():
	if game_level:
		game_level.start_level()
