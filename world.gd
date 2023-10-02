extends Node2D

@export var guard_scene: PackedScene
@export var worker_scene: PackedScene
@export var upgrade_chip_scene: PackedScene

signal wave_finished
signal player_died_signal
signal start_cutscene(cutsceneID)
signal restart_game

var run_won = false

var wave_number = 0

var wave_array = [[6, .5], [8, .6], [10, 0.7], [12, 0.8], [14, 0.9], [16, 0.9], [17, 0.9], [18, 0.9], [19, 0.9], [20, 1]]

var weapon_array = [["Default", "Default description", "Default Flavortext"], ["Sniper Rifle", "High damage and accuracy, instantly hits, low rate of fire", "The sniper was introduced to train the AI with stealth and ranged combat. "], ["Shotgun", "5 bullets, high spread, low range", "Kablow!"], ["Sword", "Melee weapon, high movespeed", "The sword was introduced to train the AI with swift melee combat."]]
var utility_array = [["Default", "Default description", "Default Flavortext"], ["Teleport", "Right click to go to that location", "Advanced tech created and used to test the AI’s capability of trans-space movement."], ["Invulnerability", "Right click for one second of invulnerability", "Tech that was created to strengthen the AI’s current shell during testing."], ["Dash", "Right click to gain a burst of increased movespeed", "A program designed to disable the AI’s shell weapon speed capacity limitors."], ["Rapid Fire", "Right click to briefly increase fire speed", "A program designed to disable the AI’s weapon safety protocol during testing."]]
var passive_array = [["Default", "Default description", "Default Flavortext"], ["Blind Rage", "High damage, high spread", "Something went wrong here…The AI’s programming seemed to go haywire…"], ["Calculated Shot", "Bullets instantly hit, but have lower damage", "A tweak in the system that allowed the AI more time to aim precisely."], ["Rapid Fire", "Faster firing and more spread", "Some of the AI’s programming seems to be malfunctioning."], ["Titanium Plating", "Increased health", "A self-healing tech that was implemented in order to make the AI’s shell last longer."], ["Boosted Core", "Increased move speed", "The AI’s programming has diverted more power into the movement core."]]


func _ready():
	var player = get_node("Player")
	var main_menu = get_node("Menu")
	var pause_menu = get_node("PauseMenu")
	var death_menu = get_node("DeathMenu")
	var cutscene = get_node("Cutscene")
	player.show_textbox.connect(show_textbox)
	player.hide_textbox.connect(hide_textbox)
	player.textbox_fields.connect(textbox_fields)
	player.door_entered.connect(door_entered)
	player.player_died.connect(player_died)
	main_menu.start_game.connect(start_game)
	pause_menu.show_pop_up.connect(show_pop_up)
	pause_menu.hide_pop_up.connect(hide_pop_up)
	pause_menu.show_main_menu.connect(show_main_menu)
	death_menu.show_main_menu.connect(show_main_menu)
	death_menu.hide_death_menu.connect(hide_death_menu)
	cutscene.end_cutscene.connect(end_cutscene)
	player.set_fade.connect(set_fade)
	$fade/ColorRect.self_modulate.a8 = 0
	$TitleSoundtrack.play()
	get_tree().paused = true
	if(GlobalVariables.immediateStart):
		start_game()
		GlobalVariables.immediateStart = false
	
func set_fade(value):
	$fade/ColorRect.self_modulate.a8 = value
	if($fade/ColorRect.self_modulate.a8 >= 255):
		check_for_cutscenes()

func start_game():
	$Menu.hide()
	$PauseMenu.hide()
	get_tree().paused = false
	$MainSoundtrack.play($TitleSoundtrack.get_playback_position())
	$TitleSoundtrack.stop()
	emit_signal("restart_game")

func show_main_menu(): #we are treating this as a time the game should be totally reset
	$DeathMenu.hide()
	reset_game()
	$Menu.show()
	get_tree().paused = true

func show_pop_up():
	if(!$Menu.visible):
		$PauseMenu.show()
		get_tree().paused = true
		$CutsceneSoundtrack.play($MainSoundtrack.get_playback_position())
		$MainSoundtrack.stop()

func hide_pop_up():
	if(!$Menu.visible):
		$PauseMenu.hide()
		get_tree().paused = false
		$MainSoundtrack.play($CutsceneSoundtrack.get_playback_position())
		$CutsceneSoundtrack.stop()
		
func hide_death_menu():
	GlobalVariables.immediateStart = true
	$DeathMenu.hide()
	reset_game()

func show_textbox():
	$Textbox.show()

func hide_textbox():
	$Textbox.hide()

func door_entered():
	if(run_won):
		player_died()
	$ClosedDoorArt.show()
	$OpenDoor.hide()
	GlobalVariables.upgraded = true
	$InfoBars/VBoxContainer/Wave/WaveNum.text = str(wave_number + 1) + " of 10"

func textbox_fields(info):
	if(info.interact_type == 'dialogue'):
		pass
	elif(info.interact_type == 'door'):
		pass
	else:
		var upgradeField = info.interact_value
		$Textbox.set_upgrade(info.interact_type, upgradeField[1], upgradeField[2], upgradeField[3])
		
func reset_game():
	get_tree().reload_current_scene()
	GlobalVariables.enemy_count = 0
	GlobalVariables.spawned = 0
	GlobalVariables.wavecompleted = false
	GlobalVariables.upgraded = false
	GlobalVariables.playerHealth = 4 #the sudden camel_case has arisen
	GlobalVariables.maxPlayerHealth = 4
	GlobalVariables.utilitytimer = 0 #the sudden camel_case has gone
	GlobalVariables.utilitytimermax = 0

func check_for_cutscenes():
	var numWins = GlobalVariables.numWins
	var numResets = GlobalVariables.numResets
	check_and_play_cutscene(0, true)
	check_and_play_cutscene(1, numResets > 0)
	check_and_play_cutscene(2, numResets > 1)
	check_and_play_cutscene(3, numResets > 2)
	check_and_play_cutscene(4, numResets > 3)
	check_and_play_cutscene(5, numResets > 4)
	check_and_play_cutscene(6, numResets > 5)
	check_and_play_cutscene(7, numWins > 0)

func check_and_play_cutscene(num, condition):
	var viewed = GlobalVariables.viewedCutscenes
	if(!viewed.has(num) && condition):
		$CutsceneSoundtrack.play($MainSoundtrack.get_playback_position())
		$MainSoundtrack.stop()
		$Cutscene.show()
		$Cutscene/CanvasLayer.show()
		$Cutscene/DialogueBox.show()
		GlobalVariables.viewedCutscenes.insert(0,num)
		get_tree().paused = true
		emit_signal("start_cutscene", num)

func end_cutscene():
	$Cutscene.hide()
	$Cutscene/CanvasLayer.hide()
	$Cutscene/DialogueBox.hide()
	$MainSoundtrack.play($CutsceneSoundtrack.get_playback_position())
	$CutsceneSoundtrack.stop()
	get_tree().paused = false

func _process(delta):
	if GlobalVariables.upgraded == true:
		var remaining = get_tree().get_nodes_in_group("upgrade_chips")
		for chip in remaining:
			chip.queue_free()
		GlobalVariables.upgraded = false
	var healthBar = $InfoBars/VBoxContainer/Health/HealthBar
	var utilityBar = $InfoBars/VBoxContainer/Utility/UtilityBar
	healthBar.max_value = GlobalVariables.maxPlayerHealth
	healthBar.value = GlobalVariables.playerHealth
	if(GlobalVariables.utilitytimermax == 0):
		$InfoBars/VBoxContainer/Utility.hide()
	else:
		$InfoBars/VBoxContainer/Utility.show()
		utilityBar.max_value = GlobalVariables.utilitytimermax
		utilityBar.value = GlobalVariables.utilitytimermax - GlobalVariables.utilitytimer


func _on_spawn_timer_timeout():
	
	if GlobalVariables.spawned < wave_array[wave_number][0] && GlobalVariables.wavecompleted == false:
		var typerand = randf()
		if typerand < wave_array[wave_number][1]: #if the random number is below the difficulty, spawn a threat
			var guard = guard_scene.instantiate()
			var guard_spawn_location = get_node("SpawnPath/SpawnLocation")
			guard_spawn_location.progress_ratio = randf()
			guard.position = guard_spawn_location.position
			add_child(guard)
			GlobalVariables.spawned += 1
			GlobalVariables.enemy_count += 1
		else:
			var worker = worker_scene.instantiate()
			var worker_spawn_location = get_node("SpawnPath/SpawnLocation")
			worker_spawn_location.progress_ratio = randf()
			worker.position = worker_spawn_location.position
			add_child(worker)
			GlobalVariables.spawned += 1
	else: 
		if GlobalVariables.enemy_count == 0:
			if GlobalVariables.wavecompleted == false:
				spawn_upgrade(2000)
				spawn_upgrade(3500)
				spawn_upgrade(5000)

				print("wave complete")
				print(wave_number)
				if wave_number < wave_array.size() - 1:
					wave_number += 1
				elif(wave_number == wave_array.size() - 1):
					run_won = true
					GlobalVariables.numWins = GlobalVariables.numWins + 1
					GlobalVariables.numResets = GlobalVariables.numResets + 1
				else:
					print("finished all waves")
					
				GlobalVariables.wavecompleted = true
				wave_ended()
	
func wave_ended():
	$OpenDoor.show()
	$ClosedDoorArt.hide()
	emit_signal("wave_finished")

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
	

func _on_death_game_reset_timer_timeout():
	reset_game()
	
func player_died():
	#$DeathGameResetTimer.start()
	if(run_won):
		$"DeathMenu/MarginContainer/HBoxContainer/VBoxContainer/You won!".show()
		run_won = false
	else:
		$"DeathMenu/MarginContainer/HBoxContainer/VBoxContainer/You won!".hide()
	$InfoBars/VBoxContainer/Health/HealthBar.value = 0
	$CutsceneSoundtrack.play($MainSoundtrack.get_playback_position())
	$MainSoundtrack.stop()
	emit_signal("player_died_signal")
	$DeathMenu.show()
	get_tree().paused = true
	
