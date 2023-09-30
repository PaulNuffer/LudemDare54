extends Node2D

@export var guard_scene: PackedScene
@export var worker_scene: PackedScene



func _on_spawn_timer_timeout():
	var guard = guard_scene.instantiate()
	var worker = worker_scene.instantiate()
	
	
	var guard_spawn_location = get_node("SpawnPath/SpawnLocation")
	guard_spawn_location.progress_ratio = randf()
	print(guard_spawn_location.progress_ratio)
	print(guard_spawn_location.position)
	var worker_spawn_location = get_node("SpawnPath/SpawnLocation")
	worker_spawn_location.progress_ratio = randf()
	print(worker_spawn_location.progress_ratio)
	print(worker_spawn_location.position)
	
	guard.position = guard_spawn_location.position
	worker.position = worker_spawn_location.position
	add_child(guard)
	add_child(worker)
