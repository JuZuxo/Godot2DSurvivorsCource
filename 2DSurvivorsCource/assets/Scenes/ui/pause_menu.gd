extends CanvasLayer

@onready var panel_container = $MarginContainer/PanelContainer
var options_menu = preload("res://assets/Scenes/ui/option_menu.tscn")

var is_closing: bool


func _ready():
	get_tree().paused = true
	panel_container.pivot_offset = panel_container.size / 2
	%ResumeButton.pressed.connect(on_resume_pressed)
	%OptionButton.pressed.connect(on_options_pressed)
	%QuitButton.pressed.connect(on_quit_pressed)
	$AnimationPlayer.play("in")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func on_resume_pressed():
	$AnimationPlayer.play_backwards("in")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await  tween.finished
	get_tree().paused = false
	queue_free()
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		close()
		get_tree().root.set_input_as_handled()
		get_tree().paused = false
		


func close():
	if is_closing:
		return
	is_closing = true
	$AnimationPlayer.play_backwards("in")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await  tween.finished
	get_tree().paused = false
	queue_free()
	
func on_quit_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/Scenes/ui/main_menu.tscn")
	
func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	var options_menu_instance = options_menu.instantiate()
	add_child(options_menu_instance)
	#因此此处是add_child 按pause之后pause_menu消失 所以option也会跟着消失
	options_menu_instance.back_pressed.connect(on_option_back_pressed.bind(options_menu_instance))
	
func on_option_back_pressed(option_menu :Node):
	option_menu.queue_free()
