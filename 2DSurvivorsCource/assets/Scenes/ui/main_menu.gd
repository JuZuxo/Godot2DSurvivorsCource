extends CanvasLayer

var option_scene = preload("res://assets/Scenes/ui/option_menu.tscn")

func _ready():
	MetaProgression.save()
	%PlayButton.pressed.connect(on_play_pressed)
	%UpgradeButton.pressed.connect(on_upgrade_pressed)
	%OptionButton.pressed.connect(on_options_pressed)
	%QuitButton.pressed.connect(on_quit_pressed)
	
func on_play_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://assets/main/main.tscn")

func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	var option_scene_instance = option_scene.instantiate()
	add_child(option_scene_instance)
	option_scene_instance.back_pressed.connect(on_options_closed.bind(option_scene_instance))

func on_quit_pressed():
	get_tree().quit()

func on_options_closed(options_instance: Node):
	options_instance.queue_free()
	
func on_upgrade_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().change_scene_to_file("res://assets/Scenes/ui/meta_menu.tscn")
