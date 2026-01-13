extends StaticBody2D
class_name PHM

signal call

@onready var interaction_area : InteractionArea = $InteractionArea
@onready var ui : Control = $phm_ui/Container
@onready var progress_bar : ProgressBar = $ProgressBar


func _ready():
	call.connect(ken)
	interaction_area.interact = Callable(self, "open_phm")

func ken():
	print('yo')
	
func open_phm():
	if ui.can_open:
		if !ui.open:
			ui.displayUI(true)
			ui.open = true
		else:
			ui.displayUI(false)
			ui.open = false

#OPEN UI
func _on_interaction_area_body_entered(body):
	if body.is_in_group('player'):
		ui.can_open = true

func _on_interaction_area_body_exited(body):
	if body.is_in_group('player'):
		ui.can_open = false
		ui.displayUI(false)


#PROGRESS BAR
func scan_mode():
	pass
