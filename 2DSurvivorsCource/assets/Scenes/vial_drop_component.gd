extends Node
#敌人爆金币的组件

@export_range(0,1) var drop_percent : float = 0.5

@export var vial_scene: PackedScene
@export var health_component: Node

func _ready():
	#中途更改health_component的类，Node可以转成HealthComponent
	(health_component as HealthComponent).died.connect(on_died)  #与健康组件的信号连接
	#用于判断死亡
	
func on_died():  #敌人死亡
	var adjusted_drop_percent = drop_percent
	var experiemce_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	if experiemce_gain_upgrade_count > 0:
		adjusted_drop_percent += .1
	if randf() > adjusted_drop_percent:   #randf返回 0.0 和 1.0（包含）之间的随机浮点值。
		#如果drip_percent为0.8 ,randf为0.3，那么就掉瓶子了，也就是randf的概率是0到0.8之间
		return
	if vial_scene == null:
		return
	
	if ! owner is Node2D:   #owner是Node2D，如果不满足就return
		return
		#这个owner实际上就是敌人
	var spawn_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entites_layer")
	entities_layer.add_child(vial_instance)  #敌人获取main主节点，main主节点再add经验瓶
	vial_instance.global_position = spawn_position
	
	#这里有个bug：掉落组件在接收到Health组件的died信号的时候，他们的主节点enemy被销毁了，所以要保证销毁在最后调用
	
