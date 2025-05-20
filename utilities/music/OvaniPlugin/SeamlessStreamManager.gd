@tool
class_name SeamlessStreamManager
extends Node

var seamless_stream : WeakRef
var poly_man : WeakRef
var last_song : AudioStream
var last_RT : float
var cur_song_length : float

var current_playbacks : Array[int] = []

var curTime : float
func _process(delta: float) -> void:
	if (poly_man == null) or (seamless_stream == null):
		queue_free();
		return;
	
	var curStream : SeamlessStream = seamless_stream.get_ref()
	var curPoly : AudioStreamPlaybackPolyphonic = poly_man.get_ref()
	if (curStream == null) or (curPoly == null):
		queue_free();
		return;
	
	if (last_song != curStream.Song) or (last_RT != curStream.ReverbTail):
		last_song = curStream.Song
		last_RT = curStream.ReverbTail
		
		for cur_play in current_playbacks:
			curPoly.stop_stream(cur_play)
		current_playbacks = []
		
		curTime = 0
		if curStream.Song != null:
			current_playbacks = [curPoly.play_stream(curStream.Song)]
			cur_song_length = curStream.Song.get_length() - last_RT
	
	if (last_song != null):
		if (curTime > cur_song_length):
			current_playbacks.append(curPoly.play_stream(curStream.Song))
			if len(current_playbacks) > 2:
				curPoly.stop_stream(current_playbacks.pop_front())
			curTime = 0
	
	curTime += delta * Engine.time_scale
