extends Node2D
class_name GrabController

@export var grab_button := MOUSE_BUTTON_LEFT

var held_object: GrabbableRigid = null

func _input(event):
	if event is InputEventMouseButton and event.button_index == grab_button:
		if event.pressed:
			try_grab()
		else:
			release()

func try_grab() -> void:
	if held_object:
		return

	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state

	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_point(query)

	if result.is_empty():
		return

	var collider = result[0].collider
	if collider is GrabbableRigid:
		held_object = collider
		held_object.grab(mouse_pos)


func release() -> void:
	if held_object:
		held_object.release()
		held_object = null
