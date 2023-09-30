extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

@export var bullet_speed = 3000

@export var damage = 1
@export var spread = 100

func _physics_process(delta):
	global_rotation = velocity.angle()
	
	move_and_collide(velocity.normalized() * delta * bullet_speed) 
	
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider().has_method("kill"):
			ray_cast_2d.get_collider().kill()
		queue_free()

func _ready():
	var standardDir = velocity.angle() * 180 / PI
	var newDir = (standardDir + randf_range(spread * -1, spread)) * PI / 180
	set_velocity(Vector2.from_angle(newDir))

