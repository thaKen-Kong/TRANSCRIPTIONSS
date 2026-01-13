extends StaticBody2D
class_name DNA_MT

@export var dna_mission_terminal : PackedScene
@onready var interaction_area : InteractionArea = $InteractionArea

var is_terminal_open : bool = false

func _ready():
	interaction_area.interact = Callable(self, "open_mission_terminal")

func open_mission_terminal():
	var dna_mt_instance = dna_mission_terminal.instantiate()
	if !is_terminal_open:
		add_child(dna_mt_instance)
		is_terminal_open = true
	elif is_terminal_open:
		is_terminal_open = false
		dna_mt_instance._close()
		
	
