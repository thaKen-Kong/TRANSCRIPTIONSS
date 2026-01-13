extends CharacterBody2D
class_name Player

@export var player_ui : Control

@export var speed : float = PlayerInfo.player_info.speed

@onready var camera : Camera2D = $Camera2D

# =======================
# GRAB MECHANIC (ADDED)
# =======================
@export var grab_detector: Area2D

var nearby_object: GrabbableObject = null
var held_object: GrabbableObject = null
# =======================

func _ready():
	if player_ui:
		player_ui.label.text = str(PlayerInfo.player_info.atp_units)
		player_ui.progress_bar.value = PlayerInfo.player_info.atp_points

	# ----- GRAB SIGNALS (ADDED) -----
	if grab_detector:
		grab_detector.body_entered.connect(_on_grab_area_entered)
		grab_detector.body_exited.connect(_on_grab_area_exited)
	# --------------------------------

func _process(_delta):
	# ----- GRAB INPUT (ADDED) -----
	if Input.is_action_just_pressed("e"):
		if held_object:
			_drop_object()
		elif nearby_object:
			_grab_object(nearby_object)
	# --------------------------------

	move_and_slide()

# =======================
# GRAB FUNCTIONS (ADDED)
# =======================

func _grab_object(obj: GrabbableObject) -> void:
	held_object = obj
	obj.grab(self)

func _drop_object() -> void:
	if held_object:
		held_object.drop()
		held_object = null

func _on_grab_area_entered(area):
	var obj = area.get_parent()
	if obj is GrabbableObject:
		nearby_object = obj


func _on_grab_area_exited(area):
	var obj = area.get_parent()
	if obj is GrabbableObject:
		if obj == nearby_object:
			nearby_object = null
# =======================

func _input(event):
	if event.is_action_pressed("test_key"):
		camera.start_shake()
