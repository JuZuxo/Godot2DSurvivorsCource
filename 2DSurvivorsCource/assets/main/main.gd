extends Node

@export var end_screen_scene:PackedScene
var pause_scene = preload("res://assets/Scenes/ui/pause_menu.tscn")

func _ready():
	%Player.health_component.died.connect(on_player_died)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_scene.instantiate())
		get_tree().root.set_input_as_handled() #让输入停止继续沿着 SceneTree 向下传播。
		
func on_player_died():
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	#add之后，endScreen的ready函数就会被调用。，所以他的Ready函数应该是在这个注解这个位置执行
	#然后再set_defeat
	end_screen_instance.set_defeat()
	MetaProgression.save()
	
	
