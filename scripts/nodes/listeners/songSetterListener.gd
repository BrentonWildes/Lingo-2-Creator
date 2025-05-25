extends Receiver

@export var song_name:String = "opening_words"
@export var song_path:Resource = preload("res://assets/audio/music/the_icy_height_palette.mp3")

var ran = false
var previous_song = "default"

func _ready():
	super._ready()
	if (! musicPlayer.map.has(song_name)):
		musicPlayer.map[song_name] = song_path

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		previous_song = musicPlayer.song
		musicPlayer.song = song_name
		musicPlayer.music_play()
		ran = true

func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		musicPlayer.song = previous_song
		musicPlayer.music_play()
		ran = false
