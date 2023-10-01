extends CanvasLayer

signal show_pop_up
signal hide_pop_up
signal show_main_menu

func _process(delta):
	if Input.is_action_just_pressed("pause_menu"):
		if(get_tree().paused):
			emit_signal("hide_pop_up")
		else:
			emit_signal("show_pop_up")

func _on_close_pop_up_pressed():
	emit_signal("hide_pop_up")

func _on_menu_pressed():
	emit_signal("show_main_menu")

func _on_exit_pressed():
	get_tree().quit()
