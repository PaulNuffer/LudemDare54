extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D

func _ready():
	add_to_group("upgrade_chips")

func change_art():
	match $InteractArea.interact_type:
		"weapon" :
			$Graphics/Weapon.show()
			$Graphics/Passive.hide()
			$Graphics/Utility.hide()
		"passive" :
			$Graphics/Weapon.hide()
			$Graphics/Passive.show()
			$Graphics/Utility.hide()
		"utility" :
			$Graphics/Weapon.hide()
			$Graphics/Passive.hide()
			$Graphics/Utility.show()
