extends Node

const BASE_RANGE = 100
const BASE_DAMAGE = 15

@export var anvil_ability_scene:PackedScene

var anvil_count = 0
var additional_number = MetaProgression.get_upgrade_count("Anvil_damage")

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var additional_rotation_degrees = 360.0 / (anvil_count + 1)
	var anvil_distance = randf_range(0, BASE_RANGE)
	
	for i in (anvil_count + 1):  #加了一才是实际的铁砧数量，因为anvil_count起始为0
		#第一个i是0，所以第一个铁砧不旋转，第二个旋转120度，第三个旋转240度
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * anvil_distance)
		var query_parameters = PhysicsRayQueryParameters2D.create(player.position, spawn_position, 1)
			#create:from: Vector2, to: Vector2, collision_mask: int = 0xFFFFFFFF, exclude
			#         射线起点，       射线终点    ，  射线要找的mask物理层1 ，
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
			#检查世界上的1号地形有没有和这个射线碰撞，检查窗口中的root，2D世界有没有1号地形
		if !result.is_empty(): #result是个位置向量，如果result存在，则：
			spawn_position = result["position"]  #不知道这干嘛的
			
		var anvil_ability_instance = anvil_ability_scene.instantiate()
		get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_ability_instance)
		anvil_ability_instance.global_position = spawn_position
		anvil_ability_instance.hitbox_component.damage = BASE_DAMAGE * pow(1.5,additional_number)
		
func on_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades:Dictionary):
	#技能更新信息传到剑这里了
	if upgrade.id == "Anvil_amount": #这个是Ability存储的三个量其中之一
		anvil_count = current_upgrades["Anvil_amount"]["quantity"]
		#这里不应该加var的，加了一个之后成为函数内变量了，难怪一直没有用！！！
		#quantity本身只有1，实现了不断升级，属性越来越高的情况
		
