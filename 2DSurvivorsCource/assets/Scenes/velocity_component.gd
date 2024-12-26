extends Node

@export var max_speed: int = 40
@export var acceleration: float = 5

var velocity = Vector2.ZERO


func accelerate_to_player():
	var owner_node2d = owner as Node2D
	if owner == null:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var direction = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)  #将变量direction放入执行函数
	
	
	

func accelerate_in_direction(direction: Vector2):
	var disired_velocity = direction * max_speed
	velocity = velocity.lerp(disired_velocity , 1-exp(-acceleration * get_process_delta_time()))
	#lerp其实就是个渐近线:lerp(x,0.1)就是以x的0.1来趋近

func decelerate():
	accelerate_in_direction(Vector2.ZERO)

func move(character_boby: CharacterBody2D):
	character_boby.velocity = velocity
	character_boby.move_and_slide()
	velocity = character_boby.velocity
