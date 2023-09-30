extends Node2D

var guard_scene = preload("res://guard.tscn")


func _on_Timer_timeout():
	var guard = guard_scene.instance()
	#guard.position = Vector2
