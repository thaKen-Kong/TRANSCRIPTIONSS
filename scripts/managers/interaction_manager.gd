extends Node2D

@onready var player_ref = get_tree().get_first_node_in_group("player")
@onready var label : Label = $CanvasLayer/Label

var base_name = "[E] TO "

var active_areas : Array = []
var can_interact : bool = true


func register_area(area : InteractionArea):
	if area:
		active_areas.push_back(area)

func unregister_area(area : InteractionArea):
	var index = active_areas.find(area)
	if active_areas.size() > 0 and area:
		if index != 1:
			active_areas.remove_at(index)
		
func _process(_delta):
	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(sort_areas)
		if active_areas[0]:
			label.text = base_name + active_areas[0].action_name
		label.show()
	else:
		label.hide()
		
	
func sort_areas(area1, area2):	
	if player_ref:
		var area1_to_player = player_ref.global_position.distance_to(area1.global_position)
		var area2_to_player = player_ref.global_position.distance_to(area2.global_position)
		return area1_to_player < area2_to_player

func _input(event):
	if event.is_action_pressed("e") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true
