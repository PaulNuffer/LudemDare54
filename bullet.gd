extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var bullet_speed = 3000

func _physics_process(delta):
	global_rotation = velocity.angle()
	
	move_and_collide(velocity.normalized() * delta * bullet_speed) 
	
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().has_method("kill"):
		ray_cast_2d.get_collider().kill()
		queue_free()

