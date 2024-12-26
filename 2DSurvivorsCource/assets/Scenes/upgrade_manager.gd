extends Node

  #把可以提升的技能弄成一个数组 
@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene
#没有报错，但是upgrade_screen没有显示出来，就是因为upgrade_screen_scene你放错了
#你放成card了！！
#里程碑：这里实例化都搞错了，看了半天要死人
var upgrade_pool: weightedTable = weightedTable.new()  #new其实就是instantiate，专门针对gd文件的实例化
#为什么不会和敌人的weightedTable混一起
var chosen_number = 2
var upgrade_axe = preload("res://resources/upgrade/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrade/axe_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrade/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrade/sword_damage.tres")
var upgrade_player_speed = preload("res://resources/upgrade/player_speed.tres")
var upgrade_anvil = preload("res://resources/upgrade/anvil.tres")
var upgrade_anvil_amount = preload("res://resources/upgrade/anvil_amount.tres")
var upgrade_heal = preload("res://resources/upgrade/heal2hp.tres")
var upgrade_range = preload("res://resources/upgrade/experience_range.tres")


func _ready():  #这里的add_item与敌人的是互相独立的
	upgrade_pool.add_item(upgrade_axe, 10)
	upgrade_pool.add_item(upgrade_anvil, 10)
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	upgrade_pool.add_item(upgrade_player_speed, 10)
	upgrade_pool.add_item(upgrade_heal, 10)
	upgrade_pool.add_item(upgrade_range, 10)
	
	
	experience_manager.level_up.connect(on_level_up)
	
func pick_upgrades():  #每次升级，都会执行两次这个函数，代表着两张卡
	var chosen_upgrades: Array[AbilityUpgrade] = [] 
	var additional_number = MetaProgression.get_upgrade_count("upgrade_card_slot_increase")
	chosen_number = 2 + additional_number  #起始是2
	for i in chosen_number:  #因为现在就两个技能，所以这个重复两遍足够了，一开始chosen_upgrades是空数组啊
		if upgrade_pool.items.size() == chosen_upgrades.size(): #如果upgrade_pool也是空数组，那么不循环了
			break   #或者如果chosen_upgrades只能pick到一个元素，这个时候他们也相等，也不循环了
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades) #从升级数组里边随机选出一个元素
		#chosen_upgrades是exclude数组
		chosen_upgrades.append(chosen_upgrade)  #chosen_upgrade随机选了两次
		#filtered_upgrades = filtered_upgrades.filter(func (upgrade):\
		 #return upgrade.id != chosen_upgrade.id)
		#filter用于筛选 你没有选过的upgrade，放入数组中，#这样实现了已经pick出来的元素不能再pick了
		
	return chosen_upgrades


var current_upgrades = {} as Dictionary   #目前已经有的提升



	
func on_level_up(current_level :int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()  #这里的chosen_upgrades已经是数组了，不需要加[]
	upgrade_screen_instance.set_ability_upgrade(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_seleted.connect(on_upgrade_selected)
	#想判断是不是信号，就看后面有没有connect
	#只要接收到upgrade_screen_instance被点击后，传出来的信号，再显示升级
	
func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade)
	
func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)   #upgrade
	#此处是询问current_upgrades这本字典里边，有没有upgrade.id，也就是Sword_rate
	#upgrade作为一个AbilityUpgrade，具备着id,name和description三个变量
	if !has_upgrade:   #如果has_upgrade不存在Sword_rate，那么就可以在池子里边挑选了
		current_upgrades[upgrade.id] = {  #current_upgrades[Sword_rate]这个key = 一本新的字典（套娃）
			"resource" : upgrade,
			"quantity" : 1,
		}
		#current_upgrades输入结果示例：
		#{ "Sword_rate": { "resource": <Resource#-9223372000498547291>, "quantity": 1 } }
		#{ "Sword_rate": { "resource": <Resource#-9223372000498547291>, "quantity": 2 } }
	else:
		#如果字典已经有这个key怎么办：
		#那么就给这个词条进行升级！
		current_upgrades[upgrade.id]["quantity"] += 1  #key里边还有一个字典，把字典的字典的值提取出来了
		#upgrade.id是一个整体 这里表示Sword_rate ["quantity"]就是把他的值提取出来再加1
		#upgrade.name同理，是Sword Quickness
		
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:  #在filter函数中pool_upgrade，代表着这个数组整体
			upgrade_pool.remove_item(upgrade) #移除掉这个更新卡
			#upgrade_pool = upgrade_pool.filter(func(pool_upgrade): return pool_upgrade.id != upgrade.id)
	
	update_upgrade_pool(upgrade)
	GameEvent.emit_ability_upgrade_added(upgrade, current_upgrades)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	#if chosen_upgrade.id == "axe":
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage ,10)
		#获得斧头了才能添加upgrade_axe_damage这个技能
	elif chosen_upgrade.id == upgrade_anvil.id:
		upgrade_pool.add_item(upgrade_anvil_amount, 10)
		
		
	
	
