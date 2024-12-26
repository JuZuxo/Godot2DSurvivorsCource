extends Area2D

class_name HurtboxComponent

signal hit
@export var health_component = Node

var floating_text_scene = preload("res://assets/Scenes/ui/floating_text.tscn")

func _ready():
	#area_enter是hitboxComponent节点自带的信号
	area_entered.connect(on_area_entered)
	
	
func on_area_entered(other_area: Area2D):
	if !other_area is HitBoxComponent:   #如果不是攻击Hurt区域 碰到了 碰撞箱Hit区域 就return
		return
	
	if health_component == null:
		return
		
	var hitbox_component = other_area as HitBoxComponent  #碰到的hitbox定位成一个变量
	health_component.damage(hitbox_component.damage)     #使用健康组件的damage函数，给的参数是hitbox组件的伤害变量
	#也就是剑提供的5点
	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	
	floating_text.global_position = global_position +( Vector2.UP * 16)
	
	var format_string = "%0.1f" #显示5.8
	if round(hitbox_component.damage) == hitbox_component.damage:  #round含有四舍五入
		format_string = "%0.0f" #只显示5
	floating_text.start(format_string % hitbox_component.damage)
	
	hit.emit()
