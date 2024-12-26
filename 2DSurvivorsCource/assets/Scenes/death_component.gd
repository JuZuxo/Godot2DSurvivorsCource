extends Node2D

@export var health_component: Node
@export var sprite:Sprite2D

func _ready():
	$GPUParticles2D.texture = sprite.texture
	health_component.died.connect(on_died)
	
#出bug的原因是：动画不小心设置成了auto，所以才没执行on_died
#因为ready刚执行完就暴毙了
func on_died():
	if owner == null or not owner is Node2D:
		return
	var spawn_position = owner.global_position
	
	var entites = get_tree().get_first_node_in_group("entites_layer")  #提前获得tree，不然移除了之后没有tree了
	get_parent().remove_child(self)  #获取父节点，移除父节点中的DeathComponent
	entites.add_child(self)   #再entites_layer中往加入DeathComponent
	
	global_position = spawn_position
	$AnimationPlayer.play("default")
	$HitRandomAudioStreamPlayerComponent.play_random()
	



