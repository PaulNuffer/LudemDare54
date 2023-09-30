extends CharacterBody2D

@export var bullet_speed = 3000

func _physics_process(delta):
	move_and_collide(velocity.normalized() * delta * bullet_speed) 
	global_rotation = velocity.angle()


func _on_area_2d_body_entered(body):
	if(body.is_in_group("enemies")):
		body.kill()
