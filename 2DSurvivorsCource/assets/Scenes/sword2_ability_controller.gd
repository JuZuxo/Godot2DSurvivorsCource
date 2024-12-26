extends Node

@export var sword_ability: PackedScene
var base_wait_time #ready这里给它赋值了
var base_damage = 5  #剑提供了5点攻击
var additional_damage_percent = 1
const MAX_RANGE = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("Timer") = $Timer $就是get_node的意思
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)   #主动连接timer的自带的信号，本身timer是要带signal timeout的
# Called every frame. 'delta' is the elapsed time since the previous frame.
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)
	
func on_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades:Dictionary):
	#技能更新信息传到剑这里了
	if upgrade.id == "Sword_rate": #这个是Ability存储的三个量其中之一
		var percent_reduction = current_upgrades["Sword_rate"]["quantity"] * 0.1
		#quantity本身只有1，实现了不断升级，属性越来越高的情况
		$Timer.wait_time = base_wait_time * (1 - percent_reduction)
		$Timer.start()  #重启timer
	elif upgrade.id == "Sword_damage":
		additional_damage_percent = 1 + (current_upgrades["Sword_damage"]["quantity"] * 0.15)
	
func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	var enemies = get_tree().get_nodes_in_group("enemy")#get node group会获得一个数组
	enemies = enemies.filter(func(enemy : Node2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
		#pow(2,5)就是2^5的意思，也就是返回前者的后者exp #Return离玩家150像素的敌人位置回到filiter()函数里
		#filter筛选出了所有离玩家近的数组敌人
	)
	
	if enemies.size() == 0: #size要是0，就不执行后面的内容了
		return
		
	enemies.sort_custom(func(a: Node2D, b:Node2D):   #把离玩家最近的敌人放到第0位
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
		
	var sword_instance = sword_ability.instantiate() as Node2D
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)  #也就是让player获得main这个父节点，再让父节点生成sword
	#伤害
	sword_instance.hitbox_component.damage = base_damage * additional_damage_percent 
	
	#剑的实例化中，含有hitbox_component的damage 等于上面定义的damage
	sword_instance.global_position = enemies[0].global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0,TAU)) * 4
	#让剑的坐标加上一个 (1,0)以任意方向旋转的向量，其实问题不是很大，随便一个随机数都可以
	
	#获取敌人和剑之间的方向向量，让剑朝向敌人的方向挥舞 但是这个前提是要先让剑和敌人位置不完全重合才行
	var enemy_direction :Vector2 = enemies[0].global_position - sword_instance.global_position as Vector2
	sword_instance.rotation = enemy_direction.angle()
