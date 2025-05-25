extends Node2D

func _ready():
	if ( global.using_keyboard ):
		get_node("Shader/settings_return").grab_focus()
	settings.initSettingsMenu( "/root/settingsMenu/Shader/settingsInner/TabContainer" )
