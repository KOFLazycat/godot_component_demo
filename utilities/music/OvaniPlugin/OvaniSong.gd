@tool
@icon("res://utilities/music/OvaniPlugin/OvaniSongIcon.png")
class_name OvaniSong
## The OvaniSong Holds onto all your music variants, for use with the [OvaniPlayer].
extends Resource

@export_category("Sound Files")
## This should be set to your least intense music file.
@export var Intensity1 : AudioStream;
## This should be set to your semi-intense music file.
@export var Intensity2 : AudioStream;
## This should be set to your most intense music file.
@export var Intensity3 : AudioStream;

## Set this to any 30 second loop of your music. 
@export var Loop30 : AudioStream;
## Set this to any 60 second loop of your music.
@export var Loop60 : AudioStream;

## Set this to how long the sound should loop over itself. [br]
## This will make any songs with a Reverb Tail loop perfectly. 	
@export var ReverbTail : float;


@export_category("Default Settings")
enum OvaniMode {
	Intensities = 0, ## Determines this [OvaniSong] will play the [member Intensity1], [member Intensity2], and [member Intensity3], music files.
	Loop30 = 1, ## Determines this [OvaniSong] will play the [member Loop30] music file.
	Loop60 = 2 ## Determines this [OvaniSong] will play the [member Loop60] music file.
}
## Set this to change what linked music files will be played.
@export var SongMode : OvaniMode = OvaniMode.Intensities;
