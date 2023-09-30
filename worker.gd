extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var move_speed = 100
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

var dead = false
var opacity = 500

func _physics_process(delta):
	if dead:
		if opacity < 1:
			queue_free()
		return
		
	var dir_to_player = global_position.direction_to(player.global_position)
	velocity = dir_to_player * move_speed * -1
	move_and_slide()
	
	#if colliding with wall, enter cower state
	
	global_rotation = dir_to_player.angle()

	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		player.kill()
		
func kill():
	if dead:
		return
	dead = true
	$DeathCullTimer.start()
	$DeathSound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	z_index = -1
		


func _on_death_cull_timer_timeout():
	opacity = opacity - 5
	$Graphics/Dead/Splatter.self_modulate.a8 = opacity
	$Graphics/Dead.self_modulate.a8 = opacity - 150
	print(opacity)

func _ready():
	add_to_group('enemies')
