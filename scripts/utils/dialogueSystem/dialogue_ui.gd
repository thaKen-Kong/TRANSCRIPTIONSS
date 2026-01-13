extends CanvasLayer
class_name DialogueSystem

# Nodes
@onready var dialogue_box: Control = $DialogueBox
@onready var rich_text: RichTextLabel = $DialogueBox/RichTextLabel
@onready var continue_btn: Button = $DialogueBox/Continue
@onready var skip_btn: Button = $DialogueBox/Skip

# Dialogue queue
var dialogue_queue: Array = []  # Array of strings
var current_text: String = ""  # Current line

func _ready() -> void:
	# Hide dialogue box and buttons by default
	dialogue_box.visible = false
	continue_btn.visible = false
	skip_btn.visible = false

	continue_btn.pressed.connect(_on_continue_pressed)
	skip_btn.pressed.connect(_on_skip_pressed)

# Start dialogue: pass an array of strings
func start_dialogue(lines: Array) -> void:
	if lines.size() == 0:
		return

	dialogue_queue = lines.duplicate()
	_show_next_line()

# Show next line
func _show_next_line() -> void:
	if dialogue_queue.size() == 0:
		_hide_dialogue()
		return

	current_text = dialogue_queue.pop_front()
	rich_text.set_bbcode(current_text)
	dialogue_box.visible = true
	continue_btn.visible = true
	skip_btn.visible = true

# Continue button
func _on_continue_pressed() -> void:
	_show_next_line()

# Skip button
func _on_skip_pressed() -> void:
	_hide_dialogue()

# Internal: hide everything
func _hide_dialogue() -> void:
	dialogue_box.visible = false
	continue_btn.visible = false
	skip_btn.visible = false
	rich_text.clear()
	dialogue_queue.clear()
