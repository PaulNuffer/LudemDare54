extends CharacterBody2D

var bullet_speed = 300

func _physics_process(delta):
	set_velocity(Vector2(1,10))
	move_and_collide(velocity.normalized() * delta * bullet_speed) 
