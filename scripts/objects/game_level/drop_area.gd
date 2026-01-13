extends Area2D
class_name DropPlace

@export var accepted_tag: String = ""   # string to match with GrabbableObject.object_tag
@export var snap_speed := 10.0          # speed of snapping

signal object_placed(obj)

var snapping_objects: Array[GrabbableObject] = []

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	for obj in snapping_objects:
		if obj == null:
			continue

		# Smoothly move object to drop place
		obj.global_position = obj.global_position.lerp(global_position, snap_speed * delta)
		if obj.sprite.scale != obj.default_scale:
			obj.sprite.scale = obj.sprite.scale.lerp(obj.default_scale, snap_speed * delta)

		# When close enough, finalize
		if obj.global_position.distance_to(global_position) < 1.0:
			snapping_objects.erase(obj)
			obj.drop()
			print("DROPPED IN THE AREA:", obj.name)
			emit_signal("object_placed", obj)

func _on_area_entered(area):
	if area.get_parent() is GrabbableObject:
		var obj: GrabbableObject = area.get_parent()
		if obj.object_tag != accepted_tag:
			return

		if obj not in snapping_objects:
			snapping_objects.append(obj)
			obj.is_held = false
			obj.holder = null
