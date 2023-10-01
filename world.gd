extends Node2D

@export var guard_scene: PackedScene
@export var worker_scene: PackedScene
@export var upgrade_chip_scene: PackedScene

var wave_number = 0

var wave_array = [[1, .5], [15, .7], [20, 1]]

var spawned = 0





func _on_spawn_timer_timeout():
	
	if spawned < wave_array[wave_number][0]:
		var typerand = randf()
		if typerand < wave_array[wave_number][1]: #if the random number is below the difficulty, spawn a threat
			var guard = guard_scene.instantiate()
			var guard_spawn_location = get_node("SpawnPath/SpawnLocation")
			guard_spawn_location.progress_ratio = randf()
			guard.position = guard_spawn_location.position
			add_child(guard)
			spawned += 1
			GlobalVariables.enemy_count += 1
		else:
			var worker = worker_scene.instantiate()
			var worker_spawn_location = get_node("SpawnPath/SpawnLocation")
			worker_spawn_location.progress_ratio = randf()
			worker.position = worker_spawn_location.position
			add_child(worker)
			spawned+=1
	else: 
		if GlobalVariables.enemy_count == 0:
			#var upgrade1 = upgrade_chip_scene.instantiate()
			#upgrade1.position = Vector2(2000, -3000)
			#upgrade1.get_child(1).interact_label = "upgrade 1"
			#upgrade1.get_child(1).interact_label = "upgrade 1"
			#upgrade1.get_child(1).interact_type = "Weapon"
			#upgrade1.get_child(1).interact_value = ["Weapon", 2]
			#trigger upgrade screen here
			print("wave complete")
			print(wave_number)
			if wave_number < wave_array.size() - 1:
				wave_number += 1
				spawned = 0
			else:
				print("finished all waves")
	
		
		
		
		
		
