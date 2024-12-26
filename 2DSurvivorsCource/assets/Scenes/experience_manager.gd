extends Node

signal experience_updated(current_experience:float , target_experience: float)
signal level_up(new_level : int)

const TARGET_EXPERIENCE_GROWTH = 5

var current_experience = 0
var current_level = 1
var target_experience = 1


func _ready():
	GameEvent.experience_vial_collected.connect(on_experience_vial_collected)  #一开始就主动接收game event信号
	#接受到信号就执行函数on_experience_vial_collected
	
func on_experience_vial_collected(number : float):
	increment_experience(number)
	
func increment_experience(number: float):
	current_experience = min(current_experience + number, target_experience)  #要么加上number，要么等于最大经验数5
	#看谁最小，防止溢出
	experience_updated.emit(current_experience, target_experience)
	if current_experience == target_experience:
		current_level += 1
		target_experience += TARGET_EXPERIENCE_GROWTH #常数5
		current_experience = 0
		experience_updated.emit(current_experience, target_experience)
		level_up.emit(current_level)
		#再次更新信号，让ExperienceBar得到更新


	
