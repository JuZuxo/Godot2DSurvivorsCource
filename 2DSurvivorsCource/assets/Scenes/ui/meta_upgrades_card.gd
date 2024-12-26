extends PanelContainer


@onready var name_label = %NameLabel
@onready var description_label = %DescriptionLabel
@onready var progress_bar = %ProgressBar
@onready var puchase_button = %PuchaseButton
@onready var progress_label = %ProgressLabel
@onready var count_label = %CountLabel


var upgrade: MetaUpgrades

func _ready():
	puchase_button.pressed.connect(on_purchase_pressed)
	#gui_input.connect(on_gui_input)   #主动连接Control子节点的信号gui_input，control是隐藏子节点
	
func update_progress():
	var current_quantity = 0
	if MetaProgression.save_data["meta_upgrades"].has(upgrade.id):
		current_quantity = MetaProgression.save_data["meta_upgrades"][upgrade.id]["quantity"]
	var is_maxed = current_quantity >= upgrade.max_quantity
	#is_maxed是个bool值，只返回true和false
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var percent = currency / upgrade.experience_cost
	#metaprogression的Savedata为0123456， 除以这个upgrade的experience_cost就是百分比
	percent = min(percent, 1)
	progress_bar.value = percent
	puchase_button.disabled = percent < 1 or is_maxed
	if is_maxed:
		puchase_button.text = "Max"
	#这个按钮的disabled属性，由 percent < 1的true或false决定
	progress_label.text = str(currency) + "/" + str(upgrade.experience_cost)
	count_label.text = "%d" %  current_quantity + " / " + str(upgrade.max_quantity)

func play_discard():
	$AnimationPlayer.play("discard")

func selected_card():
	$AnimationPlayer.play("selected")  #被点击的卡执行选择动画
	#获取其他卡牌的分组，如果other_card是选择的卡牌他自己，那么继续筛选其他的other_card
	

func set_meta_upgrade(upgrade: MetaUpgrades):
	self.upgrade = upgrade    #这个场景的var的upgrade等于函数代入得的upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()
	
#func on_gui_input(event: InputEvent):
	#if event.is_action_pressed("left_click"):
		#selected_card()
	
func on_purchase_pressed():
	if upgrade == null:
		return
	MetaProgression.add_meta_upgrades(upgrade)
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.experience_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card","update_progress")
	#调用meta_upgrade_card这个组的update_progress函数method
	$AnimationPlayer.play("selected")
