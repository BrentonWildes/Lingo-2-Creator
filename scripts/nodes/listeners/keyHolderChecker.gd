extends Node

signal trigger
signal untrigger
signal trigger_letter

var map = { 
	"control_center.keyHolder" : "z",
	"control_center.keyHolder2": "e",
	"control_center.keyHolder3": "r",
	"control_center.keyHolder4": "o",
	"four_rooms.keyHolderA": "a",
	"the_hive.keyHolderB": "b",
	"daedalus.keyHolderC": "c",
	"daedalus.keyHolderD": "d",
	"daedalus.keyHolderF": "f",
	"daedalus.keyHolderG": "g",
	"daedalus.keyHolderH": "h",
	"the_partial.keyHolderI": "l", # I screwed up lol
	"the_jubilant.keyHolderJ": "j",
	"the_tenacious.keyHolderK": "k",
	"the_unkempt.keyHolderL": "i", # this one too
	"the_unkempt.keyHolderV": "v",
	"the_unkempt.keyHolderW": "w",
	"the_extravagant.keyHolderM": "m",
	"the_shop.keyHolderN": "n",
	"the_gallery.keyHolderP": "p",
	"the_quiet.keyHolderQ": "q",
	"the_nuanced.keyHolderS": "s",
	"the_congruent.keyHolderT": "t",
	"the_parthenon.keyHolderU": "u",
	"the_great.keyHolderX": "x",
	"the_talented.keyHolderY": "y"
 }

func _ready():
	call_deferred("check")

func check():
	var count = 0
	var matches = unlocks.getAllKeyholders()
	for key_match in matches:
		var active = key_match[2] + String(key_match[3]).replace("/root/scene/Components/KeyHolders/",".")
		if map[active] == key_match[0]:
			emit_signal("trigger_letter", key_match[0], true)
			count += 1
		else:
			emit_signal("trigger_letter", key_match[0], false)
			
	if (count > 25):
		emit_signal("trigger")
