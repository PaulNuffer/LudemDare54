extends CanvasLayer

signal hide_pop_up

func _on_close_pop_up_pressed():
	emit_signal("hide_pop_up")

func _on_menu_pressed():
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()
