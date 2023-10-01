extends CanvasLayer

signal start_game

var currButton = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	emit_signal('start_game')




func _on_quit_pressed():
	get_tree().quit()
