extends CanvasLayer

signal start_game

func _on_start_button_pressed():
	emit_signal('start_game')




func _on_quit_pressed():
	get_tree().quit()
