extends Node

@export var axe_ability_scene : PackedScene

var base_damage = 10
var additional_damage_percent = 1


func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)
	
func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	var axe_instance = axe_ability_scene.instantiate() as Node2D
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
func on_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades:Dictionary):
	#技能更新信息传到剑这里了
	if upgrade.id == "Axe_damage": #这个是Ability存储的三个量其中之一
		additional_damage_percent = 1 + (current_upgrades["Axe_damage"]["quantity"] * .1)
		#quantity本身只有1，实现了不断升级，属性越来越高的情况
