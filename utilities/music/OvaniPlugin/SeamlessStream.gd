@tool
extends AudioStream
class_name SeamlessStream

@export
var Song : AudioStream 

@export
var ReverbTail : float = 1

var poly_stream : AudioStreamPolyphonic = AudioStreamPolyphonic.new()

func _instantiate_playback() -> AudioStreamPlayback:
	var playback : AudioStreamPlaybackPolyphonic = poly_stream.instantiate_playback()
	var new_manager : SeamlessStreamManager = SeamlessStreamManager.new()
	get_local_scene().add_child(new_manager, true, Node.INTERNAL_MODE_FRONT)
	new_manager.seamless_stream = weakref(self)
	new_manager.poly_man = weakref(playback)
	return playback
