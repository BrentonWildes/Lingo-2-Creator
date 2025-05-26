@tool
extends Receiver
class_name PanelMain

@export_enum ( "clue", "symbol", "answer" ) var missing_line: String = "answer"

@export var clue:String = "hi"
@export var symbol:String = "?"
@export var answer:String = "hi"
@export var achieved_text:String = ""
@export var background_materials:String
@export var can_hint = true
@export var unsolve_on_solve = false
@export var always_solvable = false
@export var proxies:Array[NodePath] = []
@export var pedestal_material:StandardMaterial3D = preload("res://assets/materials/pedestal.material")
@export var has_pedestal = true
@export var toggle_to_refresh_text_editor_mode = false
	
var active_node
var quad_mesh
var solvable

@onready var red = load("res://assets/materials/redMedium.material")
@onready var green = load("res://assets/materials/greenSuccess.material")
@onready var gray = load("res://assets/materials/grayDark.material")

var proxiables = []
var check_proxiers_on_load:Array[NodePath] = []
var is_complete = false
var has_focus = false
var correct_response = "hi"
var was_hinted = false
var play_sfx = true

signal trigger
signal untrigger
signal sfx_success
signal sfx_unsuccess

var embed_map = {
	":Syn" : "ʖ", # synonym
	":Ant" : "ʖ̓", # antonym
	":Add" : "ʘ", # add letter
	":Rem" : "ʘ̓", # remove letter
	":Adp" : "ʘ̒", # add partial letter
	":Hom" : "ʚ", # homonym
	":Rhy" : "ʚ̒", # rhyme
	":Cat" : "ʛ", # category of
	":Exa" : "ʛ̓", # example of
	":Par" : "ʓ", # part of (Horn to Rhino)
	":Who" : "ʓ̓", # whole of (Rhino to Horn)
	":Plu" : "ʜ", # pluralize
	":Sin" : "ʜ̓", # singularize
	":Int" : "ʒ", # intensify
	":Dim" : "ʒ̓", # diminish
	":Ene" : "ʔ", # energize
	":Enr" : "ʔ̓", # de-energize
	":Ent" : "ʔ̒", # transform energy
	":Swe" : "ʑ", # sweeten
	":Swu" : "ʑ̓", # unsweeten
	":Mas" : "ʕ", # masculine
	":Fem" : "ʕ̓", # feminine
	":Old" : "ʗ", # time - older
	":You" : "ʗ̓", # time - younger
	":Ten" : "ʗ̒", # time - change tense
	":Sou" : "ʐ", # sound of
	":Sor" : "ʐ̓", # sound by
	":Ana" : "ʞ", # anagram
	":Job" : "ʟ", # purpose/job (bartender to mix)
	":Emp" : "ʟ̓", # performer of purpose/job (mix to bartender)
	":Sur" : "ʡ", # surrounded by/lives in (bear to cave)
	":Srr" : "ʡ̓", # surrounding/home of (cave to bear)
	":Cha" : "Ø", # change in
	":Eva" : "ʝ", # eval
	":Sad" : "@̓", # anti-smiley
	":Odd" : "@̒", # squiggly smiley
	"." : "̘", # repeat mod
	"~" : "̒", # squiggle mod
	"^" : "̓", # negate mod
	"|" : "ɨ", # pipe separator
}

var modifiers = {
	"̞": true, # .
	"̝": true, # ..
	"̙": true, # ...
	"̘": true, # ....
	"̒": true, # squiggle
	"̓": true, # negate
}

const NEGATE = "̓"
const DOTS_1 = "̘" # .
const DOTS_2 = "̙" # ..
const DOTS_3 = "̝" # ...
const DOTS_4 = "̞" # ....

const STANDALONE_NEGATE = "ɮ"
const STANDALONE_DOTS_1 = "ɩ" # ·
const STANDALONE_DOTS_2 = "ɪ" # ··
const STANDALONE_DOTS_3 = "ɫ" # ···
const STANDALONE_DOTS_4 = "ɬ" # ····
const STANDALONE_DOTS_5 = "ɭ" # ·····

func embed( value ):
	for replace in embed_map:
		value = value.replace( replace, embed_map[replace] )
	return value

func format_dots( value ):
	# Expand dots out from combined characters into individual dots
	value = value.replace(DOTS_4, DOTS_1+DOTS_1+DOTS_1+DOTS_1)
	value = value.replace(DOTS_3, DOTS_1+DOTS_1+DOTS_1)
	value = value.replace(DOTS_2, DOTS_1+DOTS_1)
	# Then recombine them in a consistent way
	value = value.replace(DOTS_1+DOTS_1+DOTS_1+DOTS_1, DOTS_4)
	value = value.replace(DOTS_1+DOTS_1+DOTS_1, DOTS_3)
	value = value.replace(DOTS_1+DOTS_1, DOTS_2)
	return value
	
func replace_prefix(str, before, after):
	if str.begins_with(before):
		return after + str.trim_prefix(before)
	return str

func format_modifiers( value ):
	value = value.replace(" "+NEGATE, STANDALONE_NEGATE)
	value = value.replace(" "+DOTS_1, STANDALONE_DOTS_1)
	value = value.replace(" "+DOTS_2, STANDALONE_DOTS_2)
	value = value.replace(" "+DOTS_3, STANDALONE_DOTS_3)
	value = value.replace(" "+DOTS_4, STANDALONE_DOTS_4)
	value = replace_prefix(value, NEGATE, STANDALONE_NEGATE)
	value = replace_prefix(value, DOTS_1, STANDALONE_DOTS_1)
	value = replace_prefix(value, DOTS_2, STANDALONE_DOTS_2)
	value = replace_prefix(value, DOTS_3, STANDALONE_DOTS_3)
	value = replace_prefix(value, DOTS_4, STANDALONE_DOTS_4)
	value = replace_prefix(value, STANDALONE_DOTS_4+DOTS_1, STANDALONE_DOTS_5)
	return value

func placeholder( value ):
	var output = ""
	if ( was_hinted ):
		var first_letter_run = false
		for letter in value:
			if (!first_letter_run):
				output += letter
				first_letter_run = true
			else:
				if (letter != " "):
					output += "-"
				else:
					output += " "
	else:
		for letter in value:
			if ( letter != " " ):
				output += "-"
			else:
				output += " "
	return output

func setField( field, value ):
	var length = value.length()
	if ( field == "symbol" ):
		value = embed(value)
		value = format_dots(value)
		value = format_modifiers(value)
		length = 0
		for c in value:
			if c not in modifiers:
				length += 1
	
	if ( length > 8 ):
		var new_scale = 8.0 / length
		get_node("Hinge/" + field ).scale = Vector3(new_scale, new_scale, 1)
	
	if ( field == missing_line ):
		active_node = get_node("Hinge/" + field )
		correct_response = value
		if ( field == "symbol" ):
			return
		else:
			get_node("Hinge/" + field ).text = placeholder(value)
	else:
		get_node("Hinge/" + field ).text = value

func _process(_delta: float) -> void:
	if toggle_to_refresh_text_editor_mode && Engine.is_editor_hint():
		setField("clue", clue)
		setField("symbol", symbol)
		setField("answer", answer)

func _ready():
	super._ready()			
	quad_mesh = get_node("Hinge/quad").get_mesh().duplicate()
	get_node("Hinge/quad").mesh = quad_mesh
	
	if not Engine.is_editor_hint():		
		if proxies.size() > 0:
			get_node("Hinge/proxy").show()
	
	setField("clue", clue)
	setField("symbol", symbol)
	setField("answer", answer)
	
	if Engine.is_editor_hint():
		return
		
	checkSolvable(" ")
	unlocks.unlocked_key.connect(checkSolvable)
	
	for proxy in proxies:
		proxiables.push_back(get_node(proxy))
	if play_sfx:
		connect("sfx_success", sfxPlayer.sfx_play.bind("success"))
		connect("sfx_unsuccess", sfxPlayer.sfx_play.bind("unsuccess"))
		
	var mesh = get_node("Hinge/panelHolder/Hinge/MeshInstance3D")
	mesh.set_surface_override_material(0, pedestal_material)
	var mesh_bottom = get_node("Hinge/panelHolder/Hinge/MeshInstance3D2")
	mesh_bottom.set_surface_override_material(0, pedestal_material)
	
	if ! has_pedestal:
		get_node("Hinge/panelHolder").queue_free()
		
#func _set_viewport_mat(_display_mesh : MeshInstance3D, _sub_viewport : SubViewport, _surface_id : int = 0):
	#var _mat : StandardMaterial3D = StandardMaterial3D.new()
	#_mat.albedo_texture = _sub_viewport.get_texture()
	#_display_mesh.set_surface_override_material(_surface_id, _mat)

func canHint():
	if (can_hint && global.hints > 1 && !was_hinted && proxies.size() == 0 && solvable):
		return true
	else:
		return false

func hint():
	was_hinted = true
	active_node.text = placeholder( correct_response )
	#global.hints -= 1

#receive input and use it here
func passedInput(key, skip_focus_check = false):
	if ( has_focus || skip_focus_check ):
		if is_complete == false && global.allow_numbers && global.numbers_array.has(key):
			if ( active_node.text.find("-") == -1 ):
				clearKey()
			if ( key == "backspace" || key == "delete" ):
				removeKey()
			else:
				addKey(key)
				
			if ( active_node.text.to_lower().replace(" ", "") == correct_response.to_lower().replace(" ", "") ):
				if proxies.size() == 0 || !Input.is_action_pressed("crouch"):
					complete()
		elif (is_complete == false && unlocks.keys.has(key) && unlocks.keys[key]):
			if ( (key == "insert" || key == "capslock") && canHint() ):
				hint()
			elif global.letters_array.has(key):
				if ( active_node.text.find("-") == -1 ):
					clearKey()
				if ( active_node.text.find(key) == -1 || unlocks.keys[key] > 1 ):
					addKey(key)
			elif ( key == "backspace" || key == "delete" ):
				removeKey()
				
			if ( active_node.text.to_lower().replace(" ", "") == correct_response.to_lower().replace(" ", "") ):
				if proxies.size() == 0 || !Input.is_action_pressed("crouch"):
					complete()
			elif ( active_node.text.to_lower().replace(" ", "").replace("-", "").length() >= correct_response.to_lower().replace(" ", "").length() ):
				incorrect()
			else:
				possible()
			
			for proxy in proxiables:
				if ( key != "insert" && key != "capslock" ):
					proxy.passedInput(key, true)
					if proxy.is_complete:
						complete()
						possible()
						active_node.text = proxy.answer
		elif (is_complete == true):
			if ( key == "backspace" or key == "delete" ):
				uncomplete()
				clearKey()
				for proxy in proxiables:
					proxy.passedInput(key, true)

func addKey( key ):
	var pos = active_node.text.find("-")
	if ( pos != -1 && solvable ):
		active_node.text = active_node.text.erase( pos, 1 ).insert( pos, key )

func removeKey():
	var pos = active_node.text.find("-")
	if (pos == -1):
		pos = active_node.text.length()
	if (pos == 0):
		return
	active_node.text = active_node.text.erase(pos - 1, 1).insert(pos - 1, "-")

func hasKey( key ):
	return active_node.text.find(key) != -1

func complete():
	autosplitter.setLatestSolvedPanel(switcher.current_map_name, $/root/scene.get_path_to(self))
	
	get_node("/root/scene/player").solvingEnd()
	is_complete = true
	emit_signal("trigger")
	if play_sfx:
		emit_signal("sfx_success")
	get_node("Hinge/glow").hide()
	get_node("Hinge/glow_proxies").hide()
	showComplete()
	if unsolve_on_solve:
		uncomplete()

func loadData( _discard ):
	is_complete = true
	active_node.text = correct_response
	for proxy in proxiables:
		if proxy.is_complete:
			active_node.text = proxy.correct_response
		else:
			proxy.check_proxiers_on_load.push_back( get_path() )
	for proxier in check_proxiers_on_load:
		var proxier_node = get_node( proxier )
		if is_complete:
			proxier_node.active_node.text = correct_response
	emit_signal("trigger")
	#showComplete()
	checkSolvable(" ")

func uncomplete():
	is_complete = false
	emit_signal("untrigger")
	if play_sfx:
		emit_signal("sfx_unsuccess")
	if proxies.size() > 0:
		get_node("Hinge/glow_proxies").show()
	else:
		get_node("Hinge/glow").show()
	#showUnlocked()
	checkSolvable(" ")

func clearKey():
	active_node.text = placeholder(correct_response)
	active_node.set("theme_override_colors/font_color", Color(1,1,1))

func incorrect():
	active_node.set("theme_override_colors/font_color", Color(1,0,0))

func possible():
	active_node.set("theme_override_colors/font_color", Color(1,1,1))

func focus():
	if (!is_complete && solvable):
		possible()
		if proxies.size() > 0:
			get_node("Hinge/glow_proxies").show()
		else:
			get_node("Hinge/glow").show()
	has_focus = true
	global.active_panel = get_path()

func unfocus():
	if (!is_complete):
		possible()
		get_node("Hinge/glow").hide()
		get_node("Hinge/glow_proxies").hide()
		active_node.text = placeholder(correct_response)
	has_focus = false
	for proxy in proxiables:
		if !proxy.is_complete:
			proxy.active_node.text = proxy.placeholder(proxy.correct_response)

func checkSolvable(_key):
	var previous = []
	var level = 0
	solvable = true
	for letter in correct_response.to_lower():
		if letter in global.numbers_array:
			continue
		if previous.has( letter ):
			level = 2
		else:
			previous.push_back(letter)
			level = 1
		if level > unlocks.keys[letter]:
			solvable = false
			showLocked()
			return false
	if !is_complete:
		showUnlocked()
	else:
		showComplete()
	return true

func showLocked():
	if always_solvable:
		quad_mesh.surface_set_material(0, gray)
	else:
		quad_mesh.surface_set_material(0, red)

func showUnlocked():
	quad_mesh.surface_set_material(0, gray)

func showComplete():
	quad_mesh.surface_set_material(0, green)
	
func handleTriggered():
	active_node.text = correct_response
	complete()

func handleUntriggered():
	active_node.text = placeholder(correct_response)
	uncomplete()
