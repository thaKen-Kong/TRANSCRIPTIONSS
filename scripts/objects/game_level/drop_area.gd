extends Area2D
class_name DropPlace

@export var accepted_tag: String = ""   # string to match with GrabbableObject.object_tag

signal object_placed(obj)

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))

# When a grabbable object enters the drop area
func _on_area_entered(area):
	if area.get_parent() is GrabbableObject:
		var obj: GrabbableObject = area.get_parent()
		if obj.object_tag != accepted_tag:
			return

		# Set the object's near_dropplace reference
		obj.near_dropplace = self

		# Update interaction label to "Place" if being held
		if obj.is_held and obj.interaction_area:
			obj.interaction_area.action_name = "Place"

# When a grabbable object exits the drop area
func _on_area_exited(area):
	if area.get_parent() is GrabbableObject:
		var obj: GrabbableObject = area.get_parent()
		if obj.near_dropplace == self:
			obj.near_dropplace = null

			# Revert interaction label to Drop if still held
			if obj.is_held and obj.interaction_area:
				obj.interaction_area.action_name = "Drop"
