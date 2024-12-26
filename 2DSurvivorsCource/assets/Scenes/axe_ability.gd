extends Node2D

const MAX_RADIUS = 100

@onready var hitbox_component = $HitboxComponent

var base_rotation = Vector2.RIGHT

func _ready():
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 3)
	#ween_method会不断调用
	#传入的rotation变量，将会在3s内从0.0增长到2.0
	tween.tween_callback(queue_free)  #3s之后会调用callback函数
	
	
func tween_method(tween_rotation: float):
	var percent = (tween_rotation / 2)
	var current_radius = percent * MAX_RADIUS
	var current_direction = base_rotation.rotated( tween_rotation * TAU)  #rotation从0到1，相当于转1圈
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	global_position = player.global_position + (current_direction * current_radius)
	
	
	
	
