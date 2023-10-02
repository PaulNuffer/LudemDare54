extends CharacterBody2D

const bulletPath = preload('res://bullet.tscn')

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 1600
@export var health = 10
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

var dead = false
var opacity = 500

var dir_to_player
var disttoplayer

var shootoffset = randf_range(-500, 2000) #random offset of how far away from player guard will stop and shoot
var reloadtimer = 0;

func _ready():
	$Graphics/Alive.play()

func _physics_process(delta):
	if dead:
		if opacity < 1:
			queue_free()
		return
		
	if reloadtimer > 0: #decrement reload timer
		reloadtimer-=1
		
	dir_to_player = global_position.direction_to(player.global_position)
	
	disttoplayer = global_position.distance_to(player.global_position)

	#move close to player if they are far away, and run from player if they get close
	if disttoplayer < 1100 + shootoffset:
		velocity = -dir_to_player * move_speed/2
		move_and_slide()
		shoot()
	if disttoplayer > 1300 + shootoffset:
		velocity = dir_to_player * move_speed
		move_and_slide()
	if disttoplayer < 1300 + shootoffset and disttoplayer > 1100 + shootoffset:
		shoot()
		
	#global_rotation = dir_to_player.angle()
	
	#code for stopping moving and shooting instead if close enough, randomized
	
func shoot():
	if reloadtimer == 0:
		reloadtimer = 60
		createbullet()
		$GuardShootSounds.play()

func createbullet():

	#bullet code
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	bullet.ray_cast_2d.set_collision_mask_value(2, true)
	bullet.ray_cast_2d.set_collision_mask_value(3, false)
	bullet.position = global_position
	
	#this code is totally fucked because in theory it does nothing (bullet calcs its own spread) but if i remove it the game crashes lol
	var standardDir = dir_to_player.angle() * 180 / PI
	var newDir = (standardDir + randf_range(-10, 10)) * PI / 180
	bullet.velocity = Vector2.from_angle(newDir)
	
	bullet.enemy = true
	bullet.spread = 10
	bullet.damage = 1
	bullet.bullet_speed = 2000
	bullet.lifetime = 200


func hurt(damage):
	health -= damage
	if(health <= 0):
		kill()

func kill():
	if dead:
		return
	dead = true
	$DeathCullTimer.start()
	#$DeathSound.play()
	$GuardDeathSounds.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	z_index = -1
	GlobalVariables.enemy_count -= 1


func _on_death_cull_timer_timeout():
	opacity = opacity - 5
	$Graphics/Dead/Splatter.self_modulate.a8 = opacity
	$Graphics/Dead.self_modulate.a8 = opacity - 150
	#print(opacity)
