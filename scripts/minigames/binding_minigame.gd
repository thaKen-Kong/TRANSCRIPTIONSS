@tool
extends CanvasLayer
class_name binding_minigame

@export var green_screen : PackedScene
@export var red_screen : PackedScene

@onready var animation_player : AnimationPlayer = $AnimationPlayer

@onready var dna = get_tree().get_first_node_in_group("dna")
@onready var wheel_container : Node2D = $WheelContainer
@onready var valve : Sprite2D = $WheelContainer/VALVE
@onready var valve_click_area : Area2D = $WheelContainer/VALVE_CLICK_AREA
@onready var meter : TextureProgressBar = $Base/BaseContainer/ProgressBar
@onready var label : Label = $Base/BaseContainer/Label
@onready var rotation_timer : Timer = $RotationTimer

@onready var atp_label : Label = $Base/BaseContainer/ATP

@onready var RNAP : Sprite2D = $Base/BaseContainer/RNA_POLYMERASE

var progress := 0.0
var goal := 100.0
var sensitivity := 0.007
var dragging := false
var last_angle := 0.0
var minigame_active := true
var timer_started := false   # Track if timer has started

# Original scale of RNAP for reference
var RNAP_start_scale := Vector2.ONE
var RNAP_min_scale := Vector2(0.8, 0.8)  # smallest scale at full progress

# Atp Energy Reduction
var atp_reduction = 6

func _ready():
	$Base.global_position = Vector2(0, -657)
	wheel_container.global_position = Vector2(-500, 378)
	#OPEN()
	_open()
	
	#INITIALIZE ATP AMOUNT
	atp_label.text = "ATP: " + str(PlayerInfo.player_info.atp_units)
	
	RNAP_start_scale = RNAP.scale
	if animation_player:
		animation_player.play("Promoter_Region_Pulse")
	reset_minigame()
	rotation_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	rotation_timer.one_shot = true

func _process(delta):
	if minigame_active and timer_started:
		# Update the label with live countdown
		label.text = "Time left: %.1f s" % rotation_timer.time_left

	# Shrink RNAP based on progress
	var t = clamp(progress / goal, 0, 1.0)  # 0 → 1
	RNAP.scale = RNAP_start_scale.lerp(RNAP_min_scale, t)

func _input(event):
	if not minigame_active:
		return

	var wheel_center = wheel_container.global_position
	var mouse_pos = wheel_container.get_global_mouse_position()
	var wheel_radius = valve.texture.get_size().x * 0.5
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_pos.distance_to(wheel_center) <= wheel_radius:
				dragging = event.pressed
				if dragging:
					last_angle = (mouse_pos - wheel_center).angle()
	
	elif event is InputEventMouseMotion and dragging:
		var current_angle = (mouse_pos - wheel_center).angle()
		var delta_angle = current_angle - last_angle
		
		# Start the timer when the player rotates for the first time
		if not timer_started and abs(rad_to_deg(delta_angle)) > 0:
			rotation_timer.start()
			timer_started = true
		
		valve.rotation += delta_angle
		progress += abs(rad_to_deg(delta_angle)) * sensitivity
		meter.value = progress
		last_angle = current_angle

	# Check for completion
	if progress >= goal:
		minigame_completed()

# --- Called when the player fills the meter ---
func minigame_completed():
	if not minigame_active:
		return
	minigame_active = false
	rotation_timer.stop()  # stop the timer immediately
	if label:
		label.text = "Completed!"
	var green_screen_instance = green_screen.instantiate()
	add_child(green_screen_instance)
	await get_tree().create_timer(1).timeout
	_close()
	print("Valve minigame completed!")
	if dna:
		dna._on_phase_completed("INITIATION")
	# Additional feedback (animations, sound, etc.) can be added here

# --- Timer timeout callback ---
func _on_timer_timeout():
	if not minigame_active:
		return

	# Disable dragging immediately
	dragging = false
	minigame_active = false

	# Show timeout feedback
	label.text = "Time's up! Restarting..."
	var red_screen_instance = red_screen.instantiate()
	add_child(red_screen_instance)

	# Reduce ATP
	PlayerInfo.player_info.atp_units -= atp_reduction
	atp_label.text = "ATP: " + str(PlayerInfo.player_info.atp_units)

	# Wait before resetting
	await get_tree().create_timer(2).timeout
	reset_minigame()

func reset_minigame():
	progress = 0
	meter.value = progress
	dragging = false
	valve.rotation = 0
	minigame_active = true
	timer_started = false
	if label:
		label.text = "Rotate the valve!"
	RNAP.scale = RNAP_start_scale  # reset RNAP size

func _open():
	var tween = get_tree().create_tween()
	tween.tween_property($Base, "global_position", Vector2(0, 30), 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Base, "global_position", Vector2(0, 0), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(wheel_container, "global_position", Vector2(128, 378), 0.4).set_ease(Tween.EASE_OUT)

func _close():
	var tween = get_tree().create_tween()
	tween.tween_property($Base, "global_position", Vector2(0, 30), 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Base, "global_position", Vector2(0, -1000), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(wheel_container, "global_position", Vector2(-500, 378), 0.4).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
