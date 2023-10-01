extends Node2D

@export var guard_scene: PackedScene
@export var worker_scene: PackedScene
@export var upgrade_chip_scene: PackedScene

var wave_number = 0

var wave_array = [[1, .5], [15, .7], [20, 1]]

var weapon_array = [["Default", "Default description", "Default Flavortext"], ["Sniper Rifle", "High damage and accuracy, low rate of fire", "oh wow big gun there big boy"], ["Shotgun", "5 bullets, high spread, low range", "big boom oh man"], ["Sword", "Melee weapon, high movespeed", "mall ninja"]]
var utility_array = [["Default", "Default description", "Default Flavortext"], ["Teleport", "Right click to go to that location", "teleports behind you"]]
var passive_array = [["Default", "Default description", "Default Flavortext"], ["Blind Rage", "High damage, high spread", "RRRRAAAAAAHHHH"], ["Calculated Shot", "Bullets are hitscan, but lower damage", "point and click game"], ["Rapid Fire", "Faster firing, more spread, and homing", "the game plays itself"]]

var spawned = 0

func _ready():
	var player = get_node("Player")
	player.show_textbox.connect(show_textbox)
	player.hide_textbox.connect(hide_textbox)

func show_textbox():
	$Textbox.show()

func hide_textbox():
	$Textbox.hide()


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
			var upgrade1 = upgrade_chip_scene.instantiate()
			upgrade1.position = Vector2(2000, -3000)
			upgrade1.get_child(1).interact_label = "upgrade 1"
			upgrade1.get_child(1).interact_label = "upgrade 1"
			upgrade1.get_child(1).interact_type = "weapon"
			upgrade1.get_child(1).interact_value = ["weapon", 2]
			add_child(upgrade1)
			#trigger upgrade screen here
			print("wave complete")
			print(wave_number)
			if wave_number < wave_array.size() - 1:
				wave_number += 1
				spawned = 0
			else:
				print("finished all waves")
	
		
		
		
		
		
