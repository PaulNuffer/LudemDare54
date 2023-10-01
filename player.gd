extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D #move this down and set it in code
@onready var all_interactions = []
@onready var interactLabel = $"Interaction Components/InteractLabel"

signal show_textbox
signal hide_textbox

const bulletPath = preload('res://bullet.tscn')

#array of arrays representing the upgrades, master array pos is slot number, first element of child array is type, second element of child array is index
var upgrades = [["none", 0], ["none", 0], ["none", 0]]

#default variables (any variables not specified here are bools or 0 by default) (we could init everything as zero and have all these set in the default weapon shoot case)
var dspeed = 2000
var ddamage = 10
var dbulletspeed = 3000
var dlifetime = 100 
var dreloadtime = 50
var dbulletsize = 100


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
var canact = true

#constantly changing variables
var reloadtimer = 0;
var screenfadetimer = 0;

#reset function
func resetvars():
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
	var canact = true

var dead = false

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if reloadtimer > 0: #decrement reload timer
		reloadtimer-=1
	if screenfadetimer > 0: #decrement screen fade timer
		screenfadetimer-=1
		$fade/ColorRect.self_modulate.a8 = screenfadetimer
		if(screenfadetimer == 1):
			$fade/ColorRect.hide()
			canact = true
		
	if hitscan:
		#if the hitscan distance is zero we need to calculate it so its roughly the same as where the bullet would have ended up
		if hitscandist == 0:
			hitscandist = (bulletspeed * lifetime) * .007

		ray_cast_2d.target_position.x = hitscandist #set the raycast to the correct length
		ray_cast_2d.rotation = global_position.direction_to(get_global_mouse_position()).angle() + (randf_range(spread * -1, spread) * PI / 180) #point it at the mouse with a spread
	
	if dead:
		return
		
	#global_rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if Input.is_action_just_pressed("shoot") and canact:
		shoot()
		
		
		
func _physics_process(delta):
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
	
func kill():
	if dead:
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	hideGraphics()
	$CanvasLayer/DeathScreen.show()
	z_index = -1
	
		
func restart():
	get_tree().reload_current_scene()
	
func recalculate(): #recalculates all player variables
	resetvars() # reset variables to base
	for item in upgrades: #loop through all upgrade slots
		if item[0] == "weapon": #if any of them are weapons
			initialize_weapon_slot(item[1]) #initialize them
			
	for item in upgrades: #loop through all upgrade slots
		if item[0] == "passive": #if any of them are passives
			process_passive_slot(item[1]) #initialize them
	
	
func shoot():
	if reloadtimer == 0: #only if we can shoot
		for item in upgrades: #loop through all upgrade slots
			if item[0] == "weapon": #if any of them are weapons
				recalculate() # hacky, i dont want to do this every time we shoot
				process_weapon_slot(item[1]) #activate them
				return #and then get outta here
		process_weapon_slot(0) #if none are weapons, use default shooting behaviour
		
#creates a bullet, or a hitscan raycast
func createbullet():
	#hitscan code
	if (hitscan):
		#hurt whatever if it has a hurt method
		if ray_cast_2d.is_colliding():
			if ray_cast_2d.get_collider().has_method("hurt"):
				ray_cast_2d.get_collider().hurt(damage)
				print("dealt damage")
				
		return #dont make a bullet
		
	#bullet code
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position
	
	#this code is totally fucked because in theory it does nothing (bullet calcs its own spread) but if i remove it the game crashes lol
	var standardDir = (get_global_mouse_position() - $Marker2D.global_position).normalized().angle() * 180 / PI
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
			global_position = get_global_mouse_position() #works but is shit, make it so you cant teleport in walls and you can telefrag
		2:
			pass
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
			reloadtime = -1
		_:
			pass #default behaviour
			
	#call this whenever you would call process_passive_slot (sets the default stats for each weapon)
func initialize_weapon_slot(i):
	match i:
		1: #sniper rifle
			damage = 40
			spread = 0
			reloadtime = 200
			bulletspeed = 5000
			lifetime = 2000
			hitscan = true
		2: #shotgun
			damage = 5
			spread = 10
			lifetime = 100
		3:
			hitscan = true
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
		interactLabel.text = all_interactions[0].interact_label
		emit_signal("show_textbox")
	else:
		interactLabel.text = ""
		emit_signal("hide_textbox")
		

func execute_interaction():
	if(all_interactions):
		var cur_interaction = all_interactions[0]
		match cur_interaction.interact_type:
			"weapon" :
				upgrades[0] = cur_interaction.interact_value
				cur_interaction.get_parent().queue_free()
			"door" :
				canact = false
				screenfadetimer = 400
				$fade/ColorRect.show()
				#play a door sound here
				global_position.x = 3528
				global_position.y = 2000
