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
	player.textbox_fields.connect(textbox_fields)

func show_textbox():
	$Textbox.show()

func hide_textbox():
	$Textbox.hide()

func textbox_fields(info):
	if(info.interact_type == 'dialogue'):
		pass
	else:
		var upgradeField = info.interact_value
		$Textbox.set_upgrade(info.interact_type, upgradeField[1], upgradeField[2], upgradeField[3])

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
			spawn_upgrade(2000)
			spawn_upgrade(3500)
			spawn_upgrade(5000)
			#trigger upgrade screen here
			print("wave complete")
			print(wave_number)
			if wave_number < wave_array.size() - 1:
				wave_number += 1
				spawned = 0
			else:
				print("finished all waves")
	
func spawn_upgrade(xpos):
	var upgrade = upgrade_chip_scene.instantiate()
	upgrade.position = Vector2(xpos, -3000)
	var type = randi_range(0, 2)
	var type_array
	match type:
		0:
			type_array = weapon_array
			upgrade.get_child(1).interact_type = "weapon"
		1:
			type_array = utility_array
			upgrade.get_child(1).interact_type = "utility"
		2:
			type_array = passive_array
			upgrade.get_child(1).interact_type = "passive"
		_:
			pass
	var index = randi_range(1, type_array.size() - 1)
	upgrade.get_child(1).interact_label = "Press E to Interact"
	upgrade.get_child(1).interact_value = [index, type_array[index][0], type_array[index][1], type_array[index][2]]
	upgrade.change_art()
	add_child(upgrade)
	

	
		
		
		
