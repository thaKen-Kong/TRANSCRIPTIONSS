extends Control
class_name player_ui

@onready var progress_bar : TextureProgressBar = $ProgressBar
@onready var label : Label = $Label
@onready var atp_amount_label : Label = $ATP_ENERGY
@onready var phase_label : Label = $Base/PhaseLabel
@onready var timer_label : Label = $TimerLabel
@onready var deliveries_label : Label = $Deliveries
