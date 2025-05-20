@tool
@icon("res://utilities/music/OvaniPlugin/OvaniPlayerIcon.png")
class_name OvaniPlayer
## The OvaniPlayer will let you easily Manage dynamic music in your game, via [OvaniSong]s.
## 
## This Node will let you: [br]
## 1. Seamlessly loop the same song via "Reverb tails" [br]
## 2. Seamlessly transition through different "Intensities" & Volumes [br]
## 3. Easily fade or transition between different songs [br]
extends Node


## [OvaniSong]s in this array will play one by one, after eachother.
## Add to this directly in code, or use [method OvaniPlayer.PlaySongNow]
@export var QueuedSongs : Array[OvaniSong];

## The volume of this player in Decibels
@export_range(-80, 20) var Volume : float = 0:
	get:
		return Volume;
	set(value):
		for psm in _soundManagers:
			psm.Volume = value;
		Volume = value;
## The current intensity of the playing OvaniSong
@export_range(0, 1) var Intensity : float = 0:
	get:
		return Intensity;
	set(value):
		for psm in _soundManagers:
			psm.Intensity = value;
		Intensity = value;
## Check this to preview how your [OvaniPlayer] and [OvaniSong]s sounds in the editor. It will dequeue finished songs!
@export var PlayInEditor : bool = false;

## This is the Godot Audio Bus that your music will play through. Can be assigned dynamically.
@export var Bus : StringName = "Master":
	get:
		if _audioPlayer != null && !Engine.is_editor_hint():
			return _audioPlayer.bus;
		else:
			return Bus;
	set(value):
		Bus = value;
		if _audioPlayer != null:
			_audioPlayer.bus = value;

var _audioPlayer : AudioStreamPlayer:
	get:
		return _audioPlayer;
	set(value):
		value.bus = Bus;
		_audioPlayer = value

## Checking this will make the Queue send finished songs to the end of the queue, to infinitely loop music.
@export var LoopQueue : bool
		

## Use PlaySongNow to Replace the current OvaniSong with a new one.[br]
## Use transitionTime to govern how fast it fades to the next song.[br]
## Setting transitionTime to -1 will use the current songs reverbTail to fade.
func PlaySongNow(song : OvaniSong, transitionTime : float = -1):
	if (len(QueuedSongs) == 0):
		QueuedSongs.append(null)
	
	QueuedSongs.insert(1, song);
	if (len(_soundManagers) != 0):
		if (transitionTime == -1):
			_soundManagers[0].StartTime = (_curTime - _soundManagers[0].SongLength) + _soundManagers[0].ReverbTail;
			_soundManagers[0].FadeOut = _soundManagers[0].ReverbTail
		else:
			_soundManagers[0].StartTime = (_curTime - _soundManagers[0].SongLength) + transitionTime;
			_soundManagers[0].FadeOut = transitionTime

## Clears the song queue, and optionally fades to silence.
func StopSongsNow(transition_time : int = 0):
	if (len(QueuedSongs) > 0):
		QueuedSongs = [QueuedSongs[0]]
		PlaySongNow(null, transition_time)

func QueueSong(song : OvaniSong):
	QueuedSongs.append(song);

var _audioStreamPlayback : AudioStreamPlaybackPolyphonic; 
var _soundManagers : Array[PolySoundManager];

## [enum OvaniPlayer.NextState] is used internally by the [OvaniPlayer], don't mind it.
enum NextState {
	None = 0,
	StartedLoop = 1,
	StartedDifferent = 2
}
class PolySoundManager:
	var MyStream : AudioStreamPlaybackPolyphonic;
	var Ids : Array[int];
	var Volume : float:
		get:
			return Volume;
		set(value):
			var realIntensity : float;
			if (len(Ids) == 3):
				realIntensity = Intensity;
			else:
				realIntensity = 0;
			for i in range(len(Ids)):
				# set volume based on intensity
				# if only 1 audio id it'll just be full
				MyStream.set_stream_volume(Ids[i], linear_to_db(db_to_linear(value) * max((.5 - abs((i as float)/2 - realIntensity))/.5, 0)));
			Volume = value;
	var Intensity : float:
		get:
			return Intensity;
		set(value):
			Intensity = value;
			Volume = Volume;
	var StartTime : float;
	var SongLength : float;
	var ReverbTail : float;
	var FadeIn : float = -1;
	var FadeOut : float = -1;
	var StartedNextState : NextState = NextState.None;

func _constructPolySoundManager(song : OvaniSong) -> PolySoundManager:
	var o : PolySoundManager = PolySoundManager.new();
	o.MyStream = _audioStreamPlayback;

	if (song != null):
		if (song.SongMode == OvaniSong.OvaniMode.Intensities):
			o.Ids.append(_audioStreamPlayback.play_stream(song.Intensity1));
			o.Ids.append(_audioStreamPlayback.play_stream(song.Intensity2));
			o.Ids.append(_audioStreamPlayback.play_stream(song.Intensity3));
			o.Intensity = Intensity;
			o.SongLength = song.Intensity1.get_length();
		elif (song.SongMode == OvaniSong.OvaniMode.Loop30):
			o.Ids.append(_audioStreamPlayback.play_stream(song.Loop30));
			o.Intensity = 0;
			o.SongLength = song.Loop30.get_length();
		else:
			o.Ids.append(_audioStreamPlayback.play_stream(song.Loop60));
			o.Intensity = 0;
			o.SongLength = song.Loop60.get_length();
		o.ReverbTail = song.ReverbTail;
	
	o.Volume = Volume;
	o.StartTime = _curTime;
	return o;
 
 
func _ready():
	_audioPlayer = AudioStreamPlayer.new();
	_audioPlayer.stream = AudioStreamPolyphonic.new();
	add_child(_audioPlayer, INTERNAL_MODE_BACK);
	_audioPlayer.owner = null;
	_audioPlayer.play();
	_audioStreamPlayback = _audioPlayer.get_stream_playback();

var _startIntFadeVal : float = 0;
var _endIntFadeVal : float = 1;
var _timeIntFadeStarted : float = 0;
var _timeIntFadeEnded : float = 1;
## Use this to transition the current Intensity over time. [br]
## It's a simple alternative to setting the Intensity manually yourself each frame.
func FadeIntensity(intensity : float, transitionTime : float):
	_timeIntFadeStarted = _curTime
	_timeIntFadeEnded  = _curTime + transitionTime;
	_startIntFadeVal = Intensity;
	_endIntFadeVal = intensity;

var _startVolFadeVal : float = 0;
var _endVolFadeVal : float = 1;
var _timeVolFadeStarted : float = 0;
var _timeVolFadeEnded : float = 1;
## Use this to transition the current Decibel Volume over time. [br]
## It's a simple alternative to setting the Volume manually yourself each frame.
func FadeVolume(volume : float, transitionTime : float):
	_timeVolFadeStarted = _curTime
	_timeVolFadeEnded  = _curTime + transitionTime;
	_startVolFadeVal = Volume;
	_endVolFadeVal = volume;

## The Current time In the Current Song.
var CurrentSongTime : float:
	get:
		if (len(_soundManagers) > 0):
			return _curTime - _soundManagers[0].StartTime;
		else:
			return 0;
## The Current Length Of the Current Song.
var CurrentSongLength : float:
	get:
		if (len(_soundManagers) > 0):
			return _soundManagers[0].SongLength;
		else:
			return 0;

var _curTime : float = 500;
func _process(delta):
	if (Engine.is_editor_hint() && !PlayInEditor):
		for psm in _soundManagers:
			if (psm.StartedNextState != NextState.StartedLoop):
				psm.StartTime = (_curTime - psm.SongLength) + 1;
				psm.FadeOut = 1;
				psm.StartedNextState = NextState.StartedLoop;

	_curTime += delta / Engine.time_scale;

	
	# Intensity Fade Logic
	if (_timeIntFadeStarted < _curTime && _timeIntFadeEnded > _curTime):
		Intensity = lerp(_startIntFadeVal, _endIntFadeVal, (_curTime - _timeIntFadeStarted)/(_timeIntFadeEnded - _timeIntFadeStarted))
	# Volume Fade Logic
	if (_timeVolFadeStarted < _curTime && _timeVolFadeEnded > _curTime):
		Volume = lerp(_startVolFadeVal, _endVolFadeVal, (_curTime - _timeVolFadeStarted)/(_timeVolFadeEnded - _timeVolFadeStarted))

	# Play queued songs logic
	if (len(QueuedSongs) > 0):
		if (len(_soundManagers) == 0 && (!Engine.is_editor_hint() || PlayInEditor)):
			_soundManagers.append(_constructPolySoundManager(QueuedSongs[0]));
		for psm in _soundManagers:
			# handle fade in
			var timePlayed : float = _curTime - psm.StartTime;
			if (psm.FadeIn != -1 && timePlayed < psm.FadeIn):
				psm.Volume = linear_to_db((timePlayed / psm.FadeIn) * db_to_linear(Volume));
			
			# handle fade out
			var remainingTime : float = -(_curTime - (psm.StartTime + psm.SongLength));
			if (psm.FadeOut != -1 && remainingTime < psm.FadeOut):
				psm.Volume = linear_to_db((remainingTime / psm.FadeOut) * db_to_linear(Volume));
				
			
			if (remainingTime < psm.ReverbTail || remainingTime < psm.FadeOut):
				if (psm.StartedNextState == NextState.None):
					
					if (!Engine.is_editor_hint() || PlayInEditor):
						var nextSong : OvaniSong;
						if (len(QueuedSongs) == 1):
							nextSong = QueuedSongs[0];
							psm.StartedNextState = NextState.StartedLoop;
						else:
							nextSong = QueuedSongs[1];
							psm.StartedNextState = NextState.StartedDifferent;
						var newPSM : PolySoundManager = _constructPolySoundManager(nextSong)
						_soundManagers.append(newPSM);
						if remainingTime < psm.FadeOut:
							newPSM.FadeIn = psm.FadeOut;
				if (remainingTime < 0):
					_soundManagers.erase(psm);
					for id in psm.Ids:
						psm.MyStream.stop_stream(id);
					if (psm.StartedNextState == NextState.StartedDifferent):
						var leavingSong : OvaniSong = QueuedSongs.pop_front()
						if LoopQueue:
							QueuedSongs.append(leavingSong);
						notify_property_list_changed();
				
		return;
