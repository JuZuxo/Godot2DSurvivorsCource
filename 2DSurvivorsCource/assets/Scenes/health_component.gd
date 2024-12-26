extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@export var max_health:float = 1
var current_health

func _ready():
	current_health = max_health

func damage(damage_amount:float):
	current_health = clamp(current_health - damage_amount, 0 , max_health) 
	#clamp函数，返回不小于 min 且不大于 max 的 Variant 也就是返回中间值
	#这里0 , max_health是定值，他们谁是中间数，由current_health - damage_amount决定
	health_changed.emit()
	if damage_amount > 0:
		health_decreased.emit()
	Callable(check_death).call_deferred()  #calll_deferred的用处是，下一个空闲帧再调用check_death

func heal(heal_amount:int):
	damage(-heal_amount)
#这里有个bug：掉落组件在接收到Health组件的died信号的时候，他们的主节点enemy被销毁了，所以要保证销毁在最后调用
#calll_deferred的用处是，下一个空闲帧再调用check_death，先让掉落组件执行完毕
func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health , 1) # 要么0.8，要么1
	
	
func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()  #这个HealthComponent组件，会让他的父节点Owner暴毙，放谁底下谁死
	
	
	
	
	
