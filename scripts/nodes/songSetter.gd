extends Node3D
class_name SongSetter

@export var song_name:String = "opening_words"
@export var song_path:Resource = preload("res://assets/audio/music/the_icy_height_palette.mp3")

func _ready():
	if (! musicPlayer.all_tracks.has(song_name)):
		musicPlayer.all_tracks[song_name] = song_path
