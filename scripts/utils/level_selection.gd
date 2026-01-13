extends CanvasLayer

# =========================
# UI references
# =========================
@onready var base_container : Control = $Control
@onready var play_button: Button = $Control/Base/LevelInfo/Button
@onready var level_name_label: Label = $Control/Base/LevelInfo/LEVELDET
@onready var deliveries_label: Label = $Control/Base/LevelInfo/DELIVERIES
@onready var time_label: Label = $Control/Base/LevelInfo/TIME
@onready var dna_label: Label = $Control/Base/LevelInfo/DNA
@onready var reward_label: Label = $Control/Base/LevelInfo/REWARD

# Level buttons container
@onready var level_buttons: VBoxContainer = $Control/Base/LevelContainer/ScrollContainer/VBoxContainer

# Currently selected level config
var selected_level_config : Dictionary = {}

# =========================
# Level configurations
# =========================
var levels_config := {
	"Tutorial": {
		"dna_sequence": "ATCGATCGATCG",
		"deliveries_required": 2,
		"time_limit": 500.0,
		"reward": 5
	},
	"Level 1": {
		"dna_sequence": "GATTACAGATCA",
		"deliveries_required": 3,
		"time_limit": 200.0,
		"reward": 10
	},
	"Level 2": {
		"dna_sequence": "CCGGAATTCCGG",
		"deliveries_required": 4,
		"time_limit": 150.0,
		"reward": 15
	}
}

# =========================
func _ready():
	if base_container:
		call_deferred("_safe_open")
	
	# Connect level buttons
	for button in level_buttons.get_children():
		if button is Button:
			var level_name = button.text
			if levels_config.has(level_name):
				button.set_meta("config", levels_config[level_name])
				button.connect("pressed", Callable(self, "_on_level_button_pressed").bind(button))

	# Connect play button
	play_button.connect("pressed", Callable(self, "_on_play_pressed"))

	# Set default info
	_update_level_info({})

# =========================
# Level button pressed
func _on_level_button_pressed(button: Button):
	if button.has_meta("config"):
		selected_level_config = button.get_meta("config")
		_update_level_info(selected_level_config)

# =========================
# Update info panel
func _update_level_info(config: Dictionary) -> void:
	if config == null:
		deliveries_label.text = "Deliveries: -"
		time_label.text = "Time: -"
		reward_label.text = "Reward: -"
		dna_label.text = "DNA Seq: -"
	else:
		dna_label.text = "DNA Seq: " + str(config.get("dna_sequence", ""))
		deliveries_label.text = "Deliveries: " + str(config.get("deliveries_required", "-"))
		time_label.text = "Time: " + str(config.get("time_limit", "-")) + "s"
		reward_label.text = "Reward: " + str(config.get("reward", "-"))

# =========================
# Play button pressed
func _on_play_pressed():
	if selected_level_config == null:
		print("No level selected!")
		return

	# Store selected config in GameState
	GameState.next_level_config = selected_level_config

	# Call SceneTransition to load GAME_LEVEL scene
	_close()
	await get_tree().create_timer(0.5).timeout
	TransitionManager.change_scene("res://scenes/world/LEVEL/main_game_area.tscn")

func _safe_open():
	await get_tree().process_frame
	await _open()

func _close():
	var tween = get_tree().create_tween()
	
	tween.tween_property(base_container, "global_position", Vector2(0, 20), 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(base_container, "global_position", Vector2(0, -1000), 0.5).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()

func _open():
	
	base_container.global_position = Vector2(0, -1000)
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(base_container, "global_position", Vector2(0, 20), 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(base_container, "global_position", Vector2(0, 0), 0.2).set_ease(Tween.EASE_IN_OUT)
