extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D
@export var move_speed = 2800

const bulletPath = preload('res://bullet.tscn')

#array of arrays representing the upgrades, master array pos is slot number, first element of child array is type, second element of child array is index
var array = [["none", 0], ["none", 0], ["none", 0]]

#default variables (any variables not specified here are false or 0 by default
var dspeed = 700
var ddamage = 10
var dbulletspeed = 3000

#modified variables
var speed = dspeed
var damage = ddamage
var bulletspeed = dbulletspeed
var spread = 10
var reloadtimemod = 0
var hitscan = false
var homing = false

#reset function
func resetvars():
	var speed = dspeed
	var damage = ddamage
	var bulletspeed = dbulletspeed
	var spread = 0
	var reloadtimemod = 0
	var hitscan = false
	var homing = false
	
var dead = false
	
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	if dead:
		return
		
	global_rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if Input.is_action_just_pressed("shoot"):
		shoot()
func _physics_process(delta):
	if dead:
		return
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * move_speed
	move_and_slide()
	
func kill():
	if dead:
		return
	dead = true
	$DeathSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CanvasLayer/DeathScreen.show()
	z_index = -1
	
		
func restart():
	get_tree().reload_current_scene()
	
func shoot():
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	bullet.position = $Marker2D.global_position
	var standardDir = (get_global_mouse_position() - $Marker2D.global_position).normalized().angle() * 180 / PI
	var newDir = (standardDir + randf_range(spread * -1, spread)) * PI / 180
	bullet.velocity = Vector2.from_angle(newDir)
	bullet.spread = spread
	bullet.damage = damage
	bullet.bullet_speed = bulletspeed
	$MuzzleFlash.show()
	$MuzzleFlash/Timer.start()
	$ShootSound.play()
	#if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().has_method("kill"):
		#ray_cast_2d.get_collider().kill()
	
	#call this for stuff that is activated by the player (ie right click to go invisible) (need generic timer for temporary effects and cooldowns)
func process_utility_slot(i):
	match i:
		1:
			global_position = get_global_mouse_position()
		2:
			pass
		_:
			pass #default behaviour
	
	#call this for stuff that is always active (ie +5 weapon damage) (this will be activated once per passive chip every time you upgrade, after resetting all stats to default)
func process_passive_slot(i):
	match i:
		1:
			damage += 10
			spread += 20
		2:
			hitscan = true
			damage -= 2
		3:
			spread += 60
			homing = true
			reloadtimemod = -20
		_:
			pass #default behaviour
	
	#call this for stuff that is a weapon (ie i shouldnt have to explain) (setting the weapon sprite will happen elsewhere) (need generic timer for reload time)
func process_weapon_slot(i):
	match i:
		1:
			pass
		2:
			pass
		_:
			pass #default behaviour
