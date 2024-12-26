extends CanvasLayer
@onready var continue_button = %ContinueButton

@onready var quit_button = %QuitButton
@onready var title_label = %TitleLabel
@onready var description_label = %DescriptionLabel
@onready var panel_container = %PanelContainer


func _ready():
	MetaProgression.save()
	panel_container.pivot_offset = panel_container.size/2  #(支点在中心）
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	#	panel_container.scale = Vector2.ZERO等价，但是不这么写tween识别不出来
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true
	continue_button.pressed.connect(on_continue_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	
func set_defeat():
	title_label.text = "Defeat"
	description_label.text = "You Lost!"
	play_jungle(true)
	
func play_jungle(defeat: bool = false):
	if defeat:
		$DefeatStreamPlayer.play()
	else:
		$VictoryStreamPlayer.play()
	
	
	
func on_continue_button_pressed():	
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/Scenes/ui/meta_menu.tscn")
	#change_scene_to_file可以把main重新加载一遍

func on_quit_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/Scenes/ui/main_menu.tscn")


func _on_restart_button_pressed():
	pass # Replace with function body.
