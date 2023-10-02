extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D #move this down and set it in code
@onready var all_interactions = []
@onready var interactLabel = $"Interaction Components/InteractLabel"

signal show_textbox
signal hide_textbox
signal textbox_fields(info)
signal door_entered

const bulletPath = preload('res://bullet.tscn')

#array of arrays representing the upgrades, master array pos is slot number, first element of child array is type, second element of child array is index
var upgrades = [["weapon", 0], ["none", 0], ["none", 0]]

var doorOpen = false
var doorFade = false
var canact = true

#default variables (any variables not specified here are bools or 0 by default) (we could init everything as zero and have all these set in the default weapon shoot case)
var dspeed = 2000
var ddamage = 10
var dbulletspeed = 3000
var dlifetime = 100 
var dreloadtime = 50
var dbulletsize = 100
@onready var dbulletspawnpos = $"WeaponGraphics/Pistol/Marker2D"


#modifiable variables
var speed = dspeed
var damage = ddamage
var bulletspeed = dbulletspeed
var lifetime = dlifetime
var reloadtime = dreloadtime
var bulletsize = dbulletsize
var spread = 0
var hitscandist = 0
var hitscan = false
var homing = false
var invulnerable = false
var bulletspawnpos = dbulletspawnpos

#constantly changing variables
var reloadtimer = 0;
var screenfadetimer = 0;
var maxScreenFade = 0
var utilityactivetimer = 0

#reset function
func resetvars():
	speed = dspeed
	damage = ddamage
	bulletspeed = dbulletspeed
	lifetime = dlifetime
	reloadtime = dreloadtime
	bulletsize = dbulletsize
	spread = 0
	hitscandist = 0
	hitscan = false
	homing = false
	invulnerable = false

var dead = false

func _process(delta):
	if hitscan:
		#if the hitscan distance is zero we need to calculate it so its roughly the same as where the bullet would have ended up
		if hitscandist == 0:
			hitscandist = (bulletspeed * lifetime) * .007

		ray_cast_2d.target_position.x = hitscandist #set the raycast to the correct length
		ray_cast_2d.rotation = global_position.direction_to(get_global_mouse_position()).angle() + (randf_range(spread * -1, spread) * PI / 180) #point it at the mouse with a spread
	
	$MousePos.position = get_global_mouse_position() - $".".global_position
	
	$WeaponGraphics.rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if dead:
		return
		
	#global_rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if Input.is_action_just_pressed("shoot") and canact:
		shoot()
	if Input.is_action_just_pressed("utility") and canact:
		activateUtility()
		
		
		
func _physics_process(delta):
	if reloadtimer > 0: #decrement reload timer
			reloadtimer-=1
	if GlobalVariables.utilitytimer > 0: #decrement reload timer
		GlobalVariables.utilitytimer -= 1
	if utilityactivetimer > 0: #decrement reload timer
		utilityactivetimer-=1
		
	if utilityactivetimer == 0: #decrement reload timer
		recalculate()
		
	if (screenfadetimer > 0 || !doorFade): #decrement screen fade timer
		if !doorFade:
			if(screenfadetimer < maxScreenFade):
				screenfadetimer += 10
				$fade/ColorRect.self_modulate.a8 = screenfadetimer
			else:
				doorFade = true
				#play a door sound here
				global_position.x = 3528
				global_position.y = 2000
				doorOpen = false
				emit_signal("door_entered")
		else:
			screenfadetimer-=2
			$fade/ColorRect.self_modulate.a8 = screenfadetimer
			if(screenfadetimer <= 160 && !canact):
				canact = true
				GlobalVariables.spawned = 0
				GlobalVariables.enemy_count = 0 
				GlobalVariables.wavecompleted = false
			if(screenfadetimer <= 1):
				$fade/ColorRect.hide()
				$fade/ColorRect.self_modulate.a8 = 0
	
	if dead or !canact:
		return
	if Input.is_action_just_pressed("interact"):
		execute_interaction()

	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if(move_dir.is_zero_approx()):
		pass
	elif(move_dir.angle() > -PI/4 && move_dir.angle() < PI/4):
		hideGraphics()
		$Graphics/Right.show()
	elif(move_dir.angle() > PI/4 && move_dir.angle() < 3*PI/4):
		hideGraphics()
		$Graphics/Front.show()
	elif(move_dir.angle() > 3*PI/4 || move_dir.angle() < -3*PI/4):
		hideGraphics()
		$Graphics/Left.show()
	elif(move_dir.angle() > -3*PI/4 && move_dir.angle() < -PI/4):
		hideGraphics()
		$Graphics/Back.show()
	velocity = move_dir * speed
	move_and_slide()
	
func hideGraphics():
	$Graphics/Front.hide()
	$Graphics/Back.hide()
	$Graphics/Right.hide()
	$Graphics/Left.hide()
	
func hurt(damage):
	if (!invulnerable):
		GlobalVariables.playerHealth -= damage
		if(GlobalVariables.playerHealth <= 0):
			kill()
	
func kill():
	if dead:
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	hideGraphics()
	$CanvasLayer/DeathScreen.show()
	z_index = -1
	
func recalculate(): #recalculates all player variables
	resetvars() # reset variables to base
	for item in upgrades: #loop through all upgrade slots
		if item[0] == "weapon": #if any of them are weapons
			initialize_weapon_slot(item[1]) #initialize them
			
			$WeaponGraphics/Pistol.hide()
			$WeaponGraphics/Shotgun.hide()
			$WeaponGraphics/Sniper.hide()
			$WeaponGraphics/Sword.hide()

			match item[1]:
				1:
					$WeaponGraphics/Sniper.show()
				2:
					$WeaponGraphics/Shotgun.show()
					bulletspawnpos = $"WeaponGraphics/Shotgun/Marker2D"
				3:
					$WeaponGraphics/Sword.show()
				_:
					$WeaponGraphics/Pistol.show()
					bulletspawnpos = $"WeaponGraphics/Pistol/Marker2D"
				
	for item in upgrades: #loop through all upgrade slots
		if item[0] == "passive": #if any of them are passives
			process_passive_slot(item[1]) #initialize them
			
	
		
	
	
func shoot():
	if reloadtimer <= 0: #only if we can shoot
		for item in upgrades: #loop through all upgrade slots
			if item[0] == "weapon": #if any of them are weapons
				recalculate() # hacky, i dont want to do this every time we shoot
				process_weapon_slot(item[1]) #activate them
				return #and then get outta here
		process_weapon_slot(0) #if none are weapons, use default shooting behaviour
		
func activateUtility():
		if GlobalVariables.utilitytimer == 0: #only if we can use the utility
			for item in upgrades: #loop through all upgrade slots
				if item[0] == "utility": #if any of them are utilities
					process_utility_slot(item[1]) #activate them
		
#creates a bullet, or a hitscan raycast
func createbullet():
	#hitscan code
	if (hitscan):
		#hurt whatever if it has a hurt method
		if ray_cast_2d.is_colliding():
			if ray_cast_2d.get_collider().has_method("hurt"):
				ray_cast_2d.get_collider().hurt(damage)
		reloadtimer = reloadtime #start reloading
				
		return #dont make a bullet
		
	#bullet code
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	bullet.position = bulletspawnpos.global_position
	
	#this code is totally fucked because in theory it does nothing (bullet calcs its own spread) but if i remove it the game crashes lol
	var standardDir = (get_global_mouse_position() - bulletspawnpos.global_position).normalized().angle() * 180 / PI
	var newDir = (standardDir + randf_range(spread * -1, spread)) * PI / 180
	bullet.velocity = Vector2.from_angle(newDir)
	
	bullet.spread = spread
	bullet.damage = damage
	bullet.bullet_speed = bulletspeed
	bullet.lifetime = lifetime
	reloadtimer = reloadtime #start reloading
	
	#call this for stuff that is activated by the player (ie right click to go invisible) (need generic timer for temporary effects and cooldowns)
func process_utility_slot(i):
	match i:
		1:
			GlobalVariables.utilitytimer = 600
			GlobalVariables.utilitytimermax = GlobalVariables.utilitytimer
			
			if $MousePos.is_colliding():
				if $MousePos.get_collider().has_method("hurt"):
					$MousePos.get_collider().hurt(10000)
				elif $MousePos.get_collider().get_collision_mask_value(1) == true:
					return
				
			
			global_position = $MousePos.position + $".".global_position  #works but is shit, make it so you cant teleport in walls and you can telefrag
		2: #invulnerability
			GlobalVariables.utilitytimer = 600
			GlobalVariables.utilitytimermax = GlobalVariables.utilitytimer
			utilityactivetimer = 60
			invulnerable = true
		_:
			pass #default behaviour
	
	#call this for stuff that is always active (ie +5 weapon damage) (this will be activated once per passive chip every time you upgrade, after resetting all stats to default)
func process_passive_slot(i):
	match i:
		1: #"blind rage"
			damage += 10
			spread += 20
		2: #"calculated shot"
			hitscan = true
			spread = 0
			damage -= 2
		3: #"rapid fire"
			spread += 60
			homing = true
			reloadtime -= 30
		_:
			pass #default behaviour
			
	#call this whenever you would call process_passive_slot (sets the default stats for each weapon)
func initialize_weapon_slot(i):
	match i:
		1: #sniper rifle
			damage = 40
			spread = 0
			reloadtime = 60
			hitscandist = 10000
			hitscan = true
		2: #shotgun
			damage = 5
			spread = 10
			lifetime = 30
		3: #sword
			hitscan = true
			hitscandist = 1000
			speed += 600
			damage += 10
			reloadtime = 10
		_:
			pass #default behaviour
	
	#call this when you want to shoot (setting the weapon sprite will happen elsewhere)
func process_weapon_slot(i):
	match i:
		1: #sniper rifle (i want this to be hitscan but it doesent need to be if thatd be ass to do)
			createbullet()
			#$MuzzleFlash.show()
			#$MuzzleFlash/Timer.start()
			$ShootSound.play()

		2: #shotgun 
			for n in 5:
				createbullet()
			#$MuzzleFlash.show() # only one muzzleflash
			#$MuzzleFlash/Timer.start()
			$ShootSound.play()
			
		3: #sword
			createbullet()
			
		_: #default pistol
			createbullet()
			#$MuzzleFlash.show()
			#$MuzzleFlash/Timer.start()
			$ShootSound.play()



###Interaction Methods###

func _on_interaction_area_area_entered(area):
	all_interactions.insert(0,area)
	update_interactions()


func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if(all_interactions):
		if(all_interactions[0].interact_type == 'door' && !doorOpen):
			interactLabel.text = ""
			emit_signal("hide_textbox")
		else:
			interactLabel.text = all_interactions[0].interact_label
			if(all_interactions[0].interact_type != 'door'):
				emit_signal("show_textbox")
				emit_signal("textbox_fields", all_interactions[0])
			else:
				emit_signal("hide_textbox")
	else:
		interactLabel.text = ""
		emit_signal("hide_textbox")
		

func execute_interaction():
	if(all_interactions):
		var cur_interaction = all_interactions[0]
		match cur_interaction.interact_type:
			"weapon" :
				upgrades[0][0] = cur_interaction.interact_type
				upgrades[0][1] = cur_interaction.interact_value[0]
				cur_interaction.get_parent().queue_free()
				GlobalVariables.upgraded = true
				recalculate()
			"passive" :
				upgrades[1][0] = cur_interaction.interact_type
				upgrades[1][1] = cur_interaction.interact_value[0]
				cur_interaction.get_parent().queue_free()
				GlobalVariables.upgraded = true
				recalculate()
			"utility" :
				upgrades[2][0] = cur_interaction.interact_type
				upgrades[2][1] = cur_interaction.interact_value[0]
				cur_interaction.get_parent().queue_free()
				GlobalVariables.upgraded = true
			"door" :
				if(doorOpen == true):
					canact = false
					maxScreenFade = 350
					doorFade = false
					$fade/ColorRect.show()

func _on_world_wave_finished():
	doorOpen = true
