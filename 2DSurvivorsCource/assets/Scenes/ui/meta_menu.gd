extends CanvasLayer

@export var upgrades: Array[MetaUpgrades] = []
@onready var grid_container = %GridContainer
@onready var back_button = $MarginContainer2/BackButton


var meta_upgrade_card_scene = preload("res://assets/Scenes/ui/meta_upgrade_card.tscn")

func _ready():
	MetaProgression.save()
	back_button.pressed.connect(on_back_pressed)
	for upgrade in upgrades:
		var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instance)
		meta_upgrade_card_instance.set_meta_upgrade(upgrade)

func on_back_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://assets/Scenes/ui/main_menu.tscn")
