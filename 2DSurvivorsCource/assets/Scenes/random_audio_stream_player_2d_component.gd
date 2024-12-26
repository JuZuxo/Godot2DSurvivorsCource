extends AudioStreamPlayer2D

@export var streams: Array[AudioStream]
@export var randomize_pitch = true
@export var min_pitch = .9
@export var max_pitch =1.1

func play_random():
	if streams == null or streams.size() == 0:
		return
	#var chosen_stream = streams.pick_random()
	#stream = chosen_stream
	if randomize_pitch == true:
		pitch_scale = randf_range(min_pitch,max_pitch)
	else:
		pitch_scale = 1
		
	stream = streams.pick_random()
	play()
