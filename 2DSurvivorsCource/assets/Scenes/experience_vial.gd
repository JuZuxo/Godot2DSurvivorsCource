extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
		$Area2D.area_entered.connect(on_area_entered)  #Node2D主动连接area2D的自带信号area_entered
		#再执行相应的函数
		
func tween_collect(percent: float ,start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	
	global_position = start_position.lerp(player.global_position, percent)
	var direction_form_start = player.global_position - start_position
	
	var target_rotation = direction_form_start.angle() + rad_to_deg(90) 
	rotation = lerp_angle( rotation, target_rotation, 1-exp(-2 * get_process_delta_time()) )
	
	
func collect():
	GameEvent.emit_experience_vial_collected(1)  #弄成注解之后突然又可以了，太诡异了
	queue_free()


func disable_collision():
	collision_shape_2d.disabled = true
		
func on_area_entered(other_area: Area2D):
	Callable(disable_collision).call_deferred()  #enter完了再调用，不然容易出问题
	
	var tween = create_tween()
	tween.set_parallel()   #同时执行函数tween_method和tween_property
	tween.tween_method(tween_collect.bind(global_position), 0.0 ,1.0, 0.5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite ,"scale" ,Vector2.ZERO , 0.05).set_delay(0.45)#等一下上面0.5s的兄弟
	#设置set_ease曲线为EASE_IN_BACK，这个曲线可以让经验瓶先离开一小段时间再吸附
	tween.chain()   #与set_parallel捆绑使用
	
	tween.tween_callback(collect)  #tween执行完了就queue_free
	#global_position就是start_position，经验瓶他自己的global_positio
	#tween_method自带一个变量percent，他会从1s内从0.0变到1.0
	$RandomAudioStreamPlayer2DComponent.play_random()
