extends AudioStreamPlayer

var all_tracks = { 
	"the_icy_height_palette": preload("res://assets/audio/music/the_icy_height_palette.mp3")
}

var default_rotating_tracks = [
	"the_icy_height_palette"
]

var base_scene_mappings = {
	"the_entry" : "opening_words",
	"the_literate" : "opening_words",
	"the_liberated" : "opening_words",
	"the_lionized" : "opening_words",
	"the_revitalized" : "opening_words",
	
	"the_words" : "dissolved_digraph",
	
	"the_great" : "death_sentence",
	"the_orb" : "death_sentence",
	"the_keen" : "death_sentence",
	"the_linear" : "death_sentence",
	"the_talented": "death_sentence",
	"the_three_doors": "death_sentence",
	
	"the_gallery" : "largely_regally_gallery",
	"the_owl" : "largely_regally_gallery",
	"the_wise" : "largely_regally_gallery",
	"the_butterfly" : "largely_regally_gallery",
	"the_parthenon" : "largely_regally_gallery",
	
	"control_center" : "white_lies",
	"the_colorful" : "white_lies",
	"the_hinterlands" : "white_lies",
	"the_relentless" : "white_lies",
	"the_shop" : "white_lies",
	"the_stormy" : "white_lies",
	
	"the_plaza" : "etymology",
	"the_symbolic" : "etymology",
	"the_sirenic" : "etymology",
	
	"the_partial" : "black_eyes",
	"the_congruent" : "black_eyes",
	"the_tree" : "black_eyes",
	
	"the_impressive" : "letter_rip",
	"the_jubilant" : "letter_rip",
	"the_quiet" : "letter_rip",
	
	"the_tower" : "strange_chains",
	
	"the_darkroom" : "falling_off_a_glyph",
	"the_double_sided" : "falling_off_a_glyph",
	"the_extravagant" : "falling_off_a_glyph",
	
	"the_between": "spell_entrance",
	"the_lively": "spell_entrance",
	"the_hive": "spell_entrance",
	
	"the_digital" : "mischaracterized",
	"the_unyielding" : "mischaracterized",
	"the_nuanced" : "mischaracterized",
	"the_bearer" : "mischaracterized", 
	
	"the_wondrous" : "secret_library",
	"the_door" : "secret_library",
	
	"the_graveyard" : "wall_of_text",
	
	"the_unkempt" : "connotation_concoction",
	"the_sun_temple" : "connotation_concoction",
	
	"the_sweet" : "without_name_and_without_identity",
	"the_tenacious" : "without_name_and_without_identity",
	"the_gold" : "without_name_and_without_identity",
	"four_rooms" : "without_name_and_without_identity",
	
	"the_repetitive": "bold_strikethrough",
	
	"daedalus" : "gammadelt",
	"demo" : "the_icy_height_palette",
	
	"icarus" : "the_icy_height_palette"
}

var song = "default"
var duration = 0.1

func _init():
	bus = "Music"

func _ready():
	connect("finished", _finished)

func music_play():
	if ( settings.music ):
		if ( global.map == "the_entry" ):
			duration = 0.1
		else:
			duration = 3.0
		if ( global.map == "the_ancient" ):
			pitch_scale = 0.85
		else:
			pitch_scale = 1
		_fade_out()

func tweenOutComplete():
	stop()
	
	var percent_complete = 0.0
	
	#if stream != null:
	#	percent_complete = get_playback_position() / stream.get_length()
	
	stream = all_tracks[song]
	
	play(percent_complete * stream.get_length())
	_fade_in()
	
func tweenInComplete():
	pass

func loaded():
	var new_song
	var scene_setter = get_node_or_null("/root/scene/songSetter")
	if scene_setter:
		new_song = scene_setter.song_name
	elif base_scene_mappings.has(global.map):
		new_song = base_scene_mappings[ global.map ]
	else:
		new_song = default_rotating_tracks.pick_random()
	
	print(global.map + ": " + new_song)
	if new_song != song:
		song = new_song
		musicPlayer.music_play()

func _finished():
	play(0.0)

func _fade_in():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", settings.music_volume/100.0, duration)
	tween.tween_callback( tweenInComplete )

func _fade_out():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -50.0, duration)
	tween.tween_callback( tweenOutComplete )
