extends CanvasLayer

@onready var weapon = $MarginContainer/MarginContainer/HSplitContainer/Weapon
@onready var passive = $MarginContainer/MarginContainer/HSplitContainer/Passive
@onready var utility = $MarginContainer/MarginContainer/HSplitContainer/Utility
@onready var title = $MarginContainer/MarginContainer/HSplitContainer/HBoxContainer/UpgradeText/Title
@onready var description = $MarginContainer/MarginContainer/HSplitContainer/HBoxContainer/UpgradeText/Description
@onready var flavor = $MarginContainer/MarginContainer/HSplitContainer/HBoxContainer/UpgradeText/Description/Flavor
@onready var dialogue = $MarginContainer/MarginContainer/HSplitContainer/HBoxContainer/Dialogue

func _ready():
	set_upgrade('utility','Laser Pointer','Constant fire, low damage','Ah! My eyes!')

func set_dialogue(imgPath, dialogue):
	pass

func set_upgrade(type, titleText, descriptionText, flavorText):
	swap_upgrade_type(type)
	title.text = titleText
	description.text = descriptionText
	flavor.text = flavorText


func swap_upgrade_type(type):
	match type:
		"weapon":
			weapon.show()
			passive.hide()
			utility.hide()
			title.add_theme_color_override("font_color", Color(1,0.13,0.09))
		"passive":
			weapon.hide()
			passive.show()
			utility.hide()
			title.add_theme_color_override("font_color", Color(0,0.65,0.32))
		"utility":
			weapon.hide()
			passive.hide()
			utility.show()
			title.add_theme_color_override("font_color", Color(0.64,0.36,1))
