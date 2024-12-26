extends CanvasLayer

@export var arena_time_manager: ArenaTimeManager  #这个Node其实就是Time_manager，已经在主场景中放进去了
@onready var label = %Label

func _process(delta):
	if arena_time_manager == null:
		return
	var time_elapsed:float = arena_time_manager.get_time_elapsed()   #这里的arena_time_manager应该单独弄一个分类才对
	label.text = format_second_to_string(time_elapsed)
	
func format_second_to_string(seconds:float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)  #如果90s，那么minute等于1 剩余秒就是90-60*1
	return str(minutes) + ":" + ("%02d" %(floor(remaining_seconds)))  #02d是为了让数字强制有两位 
