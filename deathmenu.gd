extends CanvasLayer

signal show_death_menu
signal hide_death_menu
signal show_main_menu

func _on_close_pop_up_pressed():
	emit_signal("hide_pop_up")



func _on_menu_pressed():
	emit_signal("show_main_menu")

func _on_exit_pressed():
	get_tree().quit()


func _on_restart_pressed():
	pass # Replace with function body.
