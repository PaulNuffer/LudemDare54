extends CharacterBody2D

var bullet_speed = 3000

func _physics_process(delta):
	move_and_collide(velocity.normalized() * delta * bullet_speed) 
