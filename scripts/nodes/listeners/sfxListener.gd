extends Receiver

@export var effect:String = "success"
@export var effect_unsolve:String = "unsuccess"

var ran = false

signal sfx_success
signal sfx_unsuccess

func _ready():
	super._ready()
	connect("sfx_success", sfxPlayer.sfx_play.bind(effect))
	connect("sfx_unsuccess", sfxPlayer.sfx_play.bind(effect_unsolve))

func handleTriggered():
	triggered += 1
	if ( triggered >= total && !ran):
		emit_signal("sfx_success")
		ran = true

func handleUntriggered():
	triggered -= 1
	if ( triggered < total && ran ):
		emit_signal("sfx_unsuccess")
		ran = false
