extends Node2D

@export var cutscene: Cutscene


func _ready():
	pass

func start_tutorial():
	cutscene.play([
		func(): cutscene.focus_on($NucleolusNPC),
		func(): cutscene.wait(1.0),
		func(): cutscene.focus_on($player),
		func(): cutscene.wait(1.0)
	])
