extends Control


func _on_play_pressed():
	
	await get_tree().create_timer(1).timeout
	
	TransitionManager.change_scene(
	"res://scenes/world/hub.tscn"
)


func _on_exit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	pass


func _on_credits_pressed():
	pass

func _play_sfx():
	pass
