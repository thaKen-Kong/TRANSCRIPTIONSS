@tool
extends CanvasLayer
class_name promoter_region_finding

# --- Signal to tell parent the minigame is done ---
signal minigame_finished(dna_sequence: String, promoter_index: int)

@export var green_screen : PackedScene
@export var red_screen : PackedScene

@onready var base_container : Control = $base
@onready var dna_label: Label = $base/NinePatchRect/DNA_Label
@onready var title_label: Label = $base/NinePatchRect/title/minigame_title
@onready var found_sign: Label = $base/NinePatchRect/Label  # Sign node
@onready var atp_amount : Label = $base/NinePatchRect/atp_amount

# Player ATP

# --- DNA variables ---
var max_dna_length: int = 64
var tata_box: String = "TATA"
var dna_bases: Array[String] = ["A", "T", "C", "G"]

var dna_sequence: String = ""
var tata_start_index: int = -1
var found: bool = false

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

	
	
	# Make label clickable
	dna_label.mouse_filter = Control.MOUSE_FILTER_STOP
	
	#Set Atp Label
	_update_label(PlayerInfo.player_info.atp_units)
	
	# Connect input
	dna_label.connect("gui_input", Callable(self, "_on_dna_gui_input"))

	# Hide found sign initially
	if found_sign:
		found_sign.visible = false

	#Open Minigame
	_open()
	# Start minigame
	start_minigame()

func start_minigame() -> void:
	visible = true
	found = false
	
	# Hide sign at start
	if found_sign:
		found_sign.visible = false

	dna_sequence = _generate_dna_with_tata()
	tata_start_index = dna_sequence.find(tata_box)
	dna_label.text = dna_sequence
	
	print("DNA:", dna_sequence, "TATA at index:", tata_start_index)

func _generate_dna_with_tata() -> String:
	var sequence: String = ""
	for i in range(max_dna_length):
		sequence += dna_bases[rng.randi_range(0, dna_bases.size() - 1)]
	
	var insert_index: int = rng.randi_range(0, max_dna_length - tata_box.length())
	sequence = sequence.substr(0, insert_index) + tata_box + sequence.substr(insert_index + tata_box.length())
	return sequence

func _on_dna_gui_input(event: InputEvent) -> void:
	if found:
		return
	if event is InputEventMouseButton and event.pressed:
		var local_x: float = event.position.x
		var label_width: float = dna_label.size.x
		var char_width: float = label_width / float(dna_sequence.length())
		var clicked_index: int = int(local_x / char_width)
		
		if clicked_index >= tata_start_index and clicked_index < tata_start_index + tata_box.length():
			_on_tata_found()
		else:
			_on_wrong_selection()

func _on_tata_found() -> void:
	found = true
	print("Player clicked TATA correctly!")
	
	# Show the found sign
	if found_sign:
		found_sign.visible = true

	# Wait a tiny moment (optional) then close minigame
	
	var green_flash_intance = green_screen.instantiate()
	add_child(green_flash_intance)
	
	await get_tree().create_timer(1).timeout  # half-second pause for effect
	_close_minigame()

func _on_wrong_selection() -> void:
	PlayerInfo.player_info.atp_units -= 1
	
	_update_label(PlayerInfo.player_info.atp_units)
	
	var red_flash_intance = red_screen.instantiate()
	add_child(red_flash_intance)

func _close_minigame() -> void:
	# Emit a signal so the parent knows the promoter region has been found
	emit_signal("minigame_finished", dna_sequence, tata_start_index)
	_close()

func _update_label(atp : float):
	atp_amount.text = "ATP:" + str(atp)

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
