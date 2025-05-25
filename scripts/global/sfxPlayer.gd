extends AudioStreamPlayer

var map = { 
	"success"  : preload("res://assets/audio/sfx/success.mp3"),
	"unsuccess" : preload("res://assets/audio/sfx/unsuccess.mp3"),
	"success_low" : preload("res://assets/audio/sfx/success_low.mp3"),
	"unsuccess_low" : preload("res://assets/audio/sfx/unsuccess_low.mp3"),
	"pickup" : preload("res://assets/audio/sfx/pickup.mp3")
}

func _init():
	bus = "SFX"

func _ready():
	connect("finished", _finished)

func sfx_play( type ):
	#not sure I feel about this but maybe they'll be useful somehow
	#if randi_range(0,1) == 1:
	#	type += "_low"
	self.stop()
	stream = map[type]
	if settings.sound_effects:
		if global.loaded:
			self.play()

func _finished():
	self.stop()
