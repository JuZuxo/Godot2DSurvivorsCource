extends CanvasLayer

signal upgrade_seleted(upgrade: AbilityUpgrade)

@export var upgrade_card_scene : PackedScene
@onready var card_container = %CardContainer

func _ready():
	get_tree().paused = true   #一旦进入了场景树→get_tree().paused，但是因为你把upgradeScreen的process
	#属性改成了always，所以他仍然正常运行


func set_ability_upgrade(upgrades: Array[AbilityUpgrade]):
	var delay = 0
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate()
		card_container.add_child(card_instance)  #在CradContainer节点里边加入card，你可以添加实例化子节点看看效果
		#这里已经提前删除了
		card_instance.set_ability_upgrade(upgrade)  #upgrade的所有词条数组都在里边
		card_instance.play_in(delay)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		#执行函数on_upgrade_selected，同时把upgrade的三个信息传递给这个函数.id.name.description
		delay += 0.2
		
func on_upgrade_selected(upgrade: AbilityUpgrade):
	upgrade_seleted.emit(upgrade)
	$AnimationPlayer.play("out")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()
	
