extends Camera2D

var target_position = Vector2.ZERO

func _ready():
	make_current()

func _process(delta):
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20)) 
	#camera的global_position等于玩家的global_position 线性插值lerp的意思是(a=1.0 - exp(-delta * 10)=0.04081054289086
	#a约等于0.04 那么也就是算出玩家的xy坐标(263,155)中 更偏向0.04的值，也就是让计算机的global_position平移更丝滑的意思吧
	
func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:  #判断摄像头有没有获取到玩家节点，其实这个可有可无
		var player = player_nodes[0] as Node2D
		target_position = player.global_position  
