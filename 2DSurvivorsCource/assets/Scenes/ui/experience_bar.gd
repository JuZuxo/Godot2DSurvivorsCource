extends CanvasLayer

@export var experience_manager: Node   #想调用经验管理器的信号，那么你需要先调用经验管理器，安装上去
@onready var progress_bar = $MarginContainer/ProgressBar

func _ready():
	progress_bar.value = 0 #进度条的进度，为0
	experience_manager.experience_updated.connect(on_experience_updated)
	#experience_updated这个信号带着两个参数，代入到了on_experience_updated函数中去，用于更新经验条

func on_experience_updated(current_experience:float, target_experience:float):
	var percent = current_experience / target_experience
	#使用百分比的好处就是不用更新经验条的最大和最小，控制在0到1之间就Ok了
	#因为target_experience会越来越大，就形成了进度条越来越难提高的现象
	progress_bar.value = percent  #进度条的  进度
	
	
