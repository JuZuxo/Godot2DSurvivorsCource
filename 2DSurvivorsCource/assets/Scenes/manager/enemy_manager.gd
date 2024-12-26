extends Node

#窗口大小是640，360 半径可以取640/2也就是320最好 320再多加点容量
const SPAWN_RADIUS = 350

@export var basic_enemy_scenes : PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var hard_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer = %Timer

var base_spawn_time = 0
var enemy_table = weightedTable.new()   #weightedTable是一个孤零零的脚本，用new生成
var number_to_spawn = 1

func _ready():
	enemy_table.add_item(basic_enemy_scenes, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	
func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
		
	var random_direction = Vector2.RIGHT.rotated(randf_range(0,TAU))
	var spawn_position = Vector2.ZERO
	for i in 4: #（射线旋转4次90度，一定可以找到没有敌人生成的空区）
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		#以玩家为中心的圆向量，半径为330  #需要防止“擦边生成“所以需要额外增加20oB像素
		var addition_check_offset = random_direction * 20
		
		#创造一个射线PhysicsRayQueryParameters2D
		var query_parameters = PhysicsRayQueryParameters2D.create(player.position, spawn_position + addition_check_offset, 1)
		#create:from: Vector2, to: Vector2, collision_mask: int = 0xFFFFFFFF, exclude
		#         射线起点，       射线终点    ，  射线要找的mask物理层1 ，
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		#检查世界上的1号地形有没有和这个射线碰撞，检查窗口中的root，2D世界有没有1号地形
	#result是一个空字典，而不是null
		if result.is_empty():
			#如果射线没遇到外界墙壁，那么返回spawn_position给函数，这个循环不再执行
			#return有break的效果，你也可以改成break，因为break之后，循环外面也会返回函数值spawn_position
			#return spawn_position
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))#把90度变成弧度
			#如果遇到了外界墙壁，那么旋转90度，再执行一次循环
			
	return spawn_position
	
func on_arena_difficulty_increased(arena_diffculty:int): #这个信号自带一个参数，给到这个函数
	var time_off = (0.1/12) * arena_diffculty
	time_off = min(time_off , 0.7)  #不要让减少时间变得过分大了
	%Timer.wait_time = base_spawn_time - time_off  #(1.5-减少的时间)
	if arena_diffculty == 6:  #30s时
		enemy_table.add_item(wizard_enemy_scene, 15)
	elif arena_diffculty == 12:  #60s时
		enemy_table.add_item(bat_enemy_scene, 15)
	elif arena_diffculty == 48: #240s时
		enemy_table.add_item(hard_enemy_scene, 10)
	if (arena_diffculty % 24) == 0:  #120s时翻倍敌人
		number_to_spawn += 1
		number_to_spawn = min(3, number_to_spawn)  #最多翻3倍
	
	

func on_timer_timeout():
	timer.start()
	
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	for i in number_to_spawn: # number_to_spawn起始为1
		var enemy_scene = enemy_table.pick_item()  #这个函数会return PackedScene回去
		var enemy = enemy_scene.instantiate() as Node2D
		var entities_layer = get_tree().get_first_node_in_group("entites_layer")
		entities_layer.add_child(enemy)  #获取main，然后让main来add enemy
		enemy.global_position = get_spawn_position()
