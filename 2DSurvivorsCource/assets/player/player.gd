extends CharacterBody2D

@export var arena_time_manager: Node
@export var sword_ability_controller: PackedScene
#需要加载PackedScene才可以做到instance实例化，单纯的node节点是不能这么做的

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = %HealthBar
@onready var abilities = $Abilities
@onready var animation_player = $AnimationPlayer
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var pick_collision_shape_2d = %PickCollisionShape2D


var base_range = Vector2(1,1)
var number_colliding_bodies = 0  #记录多少个敌人在碰撞玩家
var base_speed = 0

#layer代表你在哪些层，mask代表你能和哪些层发生碰撞
func _ready():
	pick_collision_shape_2d.scale = base_range
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	base_speed = velocity_component.max_speed
	$CollisionArea2D.body_entered.connect(on_body_entered)  #此处boby_enter是判断character2D这个物理节点
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer)
	health_component.health_decreased.connect(on_health_decreased)
	health_component.health_changed.connect(on_health_changed)
	GameEvent.ability_upgrade_added.connect(on_ability_upgrade_added)
	updated_health_display() #Double_Sword资源多打了一个小空格，导致自己暴毙！
	if MetaProgression.get_upgrade_count("Double_Sword") == 1:
		abilities.add_child(sword_ability_controller.instantiate()) #实例化才能Add_child
	
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades:Dictionary):
	if ability_upgrade is Ability:#斧头脚本定义的Ability类,来告诉你，你现在有一个新的斧头
		#通过这个函数实现了铁砧的加入，轮子造的非常便利，因为铁砧也是Ability类型的
		#Ability拓展了AbilityUpgrade这个脚本的tre资源文件0
		var ability = ability_upgrade as Ability  #此处把斧头，铁砧实例化
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed+ (base_speed * current_upgrades["player_speed"]["quantity"]* 0.1)
	elif ability_upgrade.id == "Heal_HP":
		health_component.heal(2)
	elif ability_upgrade.id == "experience_range":
		base_range = base_range * 1.2
		pick_collision_shape_2d.scale = base_range

				
func updated_health_display():
	health_bar.value = health_component.get_health_percent()
	
func on_health_decreased():
	GameEvent.emit_player_damaged()
	updated_health_display()
	$RandomAudioStreamPlayer2DComponent.play_random()
	
func on_health_changed():
	updated_health_display()
	
	
func on_damage_interval_timer():
	check_deal_damage()

#加个on就是信号连接函数的意思
func on_body_entered(other_body:Node2D):
	number_colliding_bodies += 1  #信号只会发出一次,不会连续发送
	check_deal_damage()

func on_body_exited(other_body:Node2D):
	number_colliding_bodies -= 1 
	check_deal_damage()
	
	
func check_deal_damage():
	if number_colliding_bodies == 0 or !damage_interval_timer.is_stopped():
		#没有敌人碰到玩家，而且无敌时间还存在
		return
	health_component.damage(1)
	damage_interval_timer.start()   #计时器设置是只触发一次


func get_movement_vector():
	#var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var x_movement = Input.get_axis("left","right")  #先负数后正数
	var y_movement = Input.get_axis("up","down")
	#如果按下右，那么会根据力度，让数为1，如果按下左，也会是1，但是因为你相减了，所以成为-1了
	#那么这个区间只会在-1和1之间，因为两个同时按会互相抵消。
	return Vector2(x_movement,y_movement)

func _process(delta):
	var movement_vector: Vector2 = get_movement_vector()
	var direction = movement_vector.normalized()  #防止根号2的出现，会把斜向上的方向变成单位长度为1的模
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)

	if movement_vector.x != 0 or movement_vector.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	var move_sign = sign(movement_vector.x) #负值返回 -1、正值返回 1，零则返回 0。如果是 nan 则返回 0
	if move_sign != 0:  #此处用于玩家的左右朝向
		visuals.scale = Vector2(move_sign, 1)
		
func on_arena_difficulty_increased(difficulty: int):
	var health_regeneration_quantity = MetaProgression.get_upgrade_count("health_regeneration")
	if health_regeneration_quantity > 0:
		var is_thirty_second_interval = (difficulty % 6) == 0  #每6相当于30s
		if is_thirty_second_interval:
			health_component.heal(health_regeneration_quantity)
	
