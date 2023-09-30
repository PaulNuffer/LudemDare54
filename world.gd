extends Node2D

@export var guard_scene: PackedScene
@export var worker_scene: PackedScene


func _on_timer_timeout():
	var guard = guard_scene.instantiate()
	var worker = worker_scene.instantiate()
	guard.position = Vector2(randi() % 1500, -20)
	worker.position = Vector2(randi() % 1500, -20)
	add_child(guard)
	add_child(worker)
