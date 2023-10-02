extends CanvasLayer

signal show_death_menu
signal hide_death_menu
signal show_main_menu

func _on_restart_pressed():
	emit_signal("hide_death_menu")

func _on_menu_pressed():
	emit_signal("show_main_menu")

func _on_exit_pressed():
	get_tree().quit()


func _on_world_player_died_signal():
	pass # Replace with function body.
